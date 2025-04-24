// lib/screens/tablet_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:signature/signature.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '../api/trabajadores_api.dart';
import '../constants.dart';
import '../models/tablet_registration.dart';
import '../services/sync_service.dart';
import 'tablet_registration_content.dart';
import 'pending_registrations_screen.dart';

class TabletRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const TabletRegistrationScreen({super.key, this.userData});

  @override
  State<TabletRegistrationScreen> createState() =>
      _TabletRegistrationScreenState();
}

class _TabletRegistrationScreenState extends State<TabletRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activoController = TextEditingController();
  final _inventarioController = TextEditingController();
  final _serieController = TextEditingController();
  final _trabajadorController = TextEditingController();
  final _chipSerieController = TextEditingController();
  final _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  String? _selectedAndroid;
  String? _selectedAnio;
  String? _selectedAgencia;
  String? _selectedProceso;
  String? _selectedCentroCosto;
  Map<String, dynamic>? _trabajadorAsignado;
  bool _isLoading = false;
  bool _isSignatureConfirmed = false;
  final List<File?> _fotos = List.filled(4, null);
  String? _selectedCategoriaFalla;
  final Map<String, Map<String, bool>> _fallasPorCategoria = {
    'Pantalla': {
      'Pantalla estrellada': false,
      'Pantalla con tinta regada': false,
      'Pantalla no prende': false,
      'Pantalla con rayas': false,
    },
    'Batería': {
      'Batería no carga': false,
      'Batería se descarga rápido': false,
      'Batería inflada': false,
    },
    'Botones': {
      'Botón de encendido no funciona': false,
      'Botones de volumen no responden': false,
    },
    'Entradas': {
      'Puerto de carga dañado': false,
      'Entrada de audífonos no funciona': false,
    },
    'Conectividad': {'Wi-Fi no conecta': false, 'Bluetooth no funciona': false},
    'Otros': {
      'Cámara no funciona': false,
      'Altavoz sin sonido': false,
      'Tableta reinicia sola': false,
    },
  };
  LatLng? _currentLocation;
  bool _isLocationLoading = false;
  final ImagePicker _picker = ImagePicker();
  final SyncService _syncService = SyncService();
  final ValueNotifier<int> _pendingCountNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _updatePendingCount();
  }

  @override
  void dispose() {
    _activoController.dispose();
    _inventarioController.dispose();
    _serieController.dispose();
    _trabajadorController.dispose();
    _chipSerieController.dispose();
    _signatureController.dispose();
    _pendingCountNotifier.dispose();
    super.dispose();
  }

  Future<void> _updatePendingCount() async {
    final count = await _syncService.getPendingCount();
    _pendingCountNotifier.value = count;
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar(AppStrings.locationError, isError: true);
        setState(() {
          _currentLocation = null;
          _isLocationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(AppStrings.permissionDeniedError, isError: true);
          setState(() {
            _currentLocation = null;
            _isLocationLoading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(AppStrings.permissionDeniedForeverError, isError: true);
        setState(() {
          _currentLocation = null;
          _isLocationLoading = false;
        });
        return;
      }

      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _currentLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
          _isLocationLoading = false;
        });
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(AppStrings.locationFetchError, isError: true);
        setState(() {
          _currentLocation = null;
          _isLocationLoading = false;
        });
      }
    }
  }

  void _retryLocation() {
    _getCurrentLocation();
  }

  Future<void> _tomarFoto(int index) async {
    setState(() => _isLoading = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null && mounted) {
        final directory = await getApplicationDocumentsDirectory();
        final photoPath =
            '${directory.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(image.path).copy(photoPath);
        setState(() => _fotos[index] = File(photoPath));
      }
    } catch (e) {
      _showSnackBar(AppStrings.errorTakingPhoto, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<File?> _saveSignature() async {
    if (_signatureController.isNotEmpty) {
      final signatureData = await _signatureController.toPngBytes(
        width: 600,
        height: 300,
      );
      if (signatureData != null) {
        final directory = await getApplicationDocumentsDirectory();
        final signatureFile =
            File('${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
        await signatureFile.writeAsBytes(signatureData);
        return signatureFile;
      }
    }
    return null;
  }

  void _confirmSignature() {
    if (_signatureController.isNotEmpty) {
      setState(() {
        _isSignatureConfirmed = true;
      });
      _showSnackBar(AppStrings.signatureConfirmed);
    } else {
      _showSnackBar(AppStrings.signatureEmptyError, isError: true);
    }
  }

  Future<void> _registrarTableta() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(AppStrings.formValidationError, isError: true);
      return;
    }
    if (_fotos.where((foto) => foto == null).isNotEmpty) {
      _showSnackBar(AppStrings.missingPhotosError, isError: true);
      return;
    }
    if (_trabajadorController.text.isNotEmpty && _trabajadorAsignado == null) {
      _showSnackBar(AppStrings.invalidWorkerRpeError, isError: true);
      return;
    }
    if (_trabajadorAsignado != null && _signatureController.isEmpty) {
      _showSnackBar(AppStrings.signatureRequiredError, isError: true);
      return;
    }
    if (_trabajadorAsignado != null && !_isSignatureConfirmed) {
      _showSnackBar(AppStrings.signatureNotConfirmedError, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<String> fotoPaths = _fotos
          .where((foto) => foto != null)
          .map((foto) => foto!.path)
          .toList();
      String? firmaPath;
      if (_trabajadorAsignado != null) {
        final signatureFile = await _saveSignature();
        if (signatureFile != null) {
          firmaPath = signatureFile.path;
        }
      }

      List<Map<String, String>> fallas = [];
      _fallasPorCategoria.forEach((categoria, fallasMap) {
        fallasMap.forEach((falla, seleccionada) {
          if (seleccionada) {
            fallas.add({'categoria': categoria, 'falla': falla});
          }
        });
      });

      // Añadir log para depurar el valor de _selectedCentroCosto
      print('Valor de _selectedCentroCosto antes de registrar: $_selectedCentroCosto');

      final registration = TabletRegistration(
        activo: _activoController.text,
        inventario: _inventarioController.text,
        numeroSerie: _serieController.text,
        versionAndroid: _selectedAndroid,
        anioAdquisicion: _selectedAnio,
        agencia: _selectedAgencia,
        proceso: _selectedProceso,
        centroCosto: _selectedCentroCosto,
        rpeTrabajador: _trabajadorAsignado?['rpe'],
        marcaChip: AppStrings.fixedChipBrand,
        numeroSerieChip: _chipSerieController.text.isEmpty
            ? null
            : _chipSerieController.text,
        ubicacionRegistro: _currentLocation != null
            ? '${_currentLocation!.latitude},${_currentLocation!.longitude}'
            : null,
        fotoPaths: fotoPaths,
        firmaPath: firmaPath,
        fallas: fallas,
        asignadaPor: widget.userData?['rpe'] ?? 'UNKNOWN',
        timestamp: DateTime.now(),
      );

      final success = await _syncService.trySendRegistration(registration);
      if (success) {
        _showSnackBar(AppStrings.registrationSuccess);
        _resetForm();
      } else {
        await _syncService.saveRegistrationLocally(registration);
        _showSnackBar(
          'Registro no enviado debido a problemas de conexión. Guardado localmente.',
          isError: true,
        );
        _resetForm();
      }
      await _updatePendingCount();
    } catch (e) {
      List<String> fotoPaths = _fotos
          .where((foto) => foto != null)
          .map((foto) => foto!.path)
          .toList();
      String? firmaPath;
      if (_trabajadorAsignado != null) {
        final signatureFile = await _saveSignature();
        if (signatureFile != null) {
          firmaPath = signatureFile.path;
        }
      }

      List<Map<String, String>> fallas = [];
      _fallasPorCategoria.forEach((categoria, fallasMap) {
        fallasMap.forEach((falla, seleccionada) {
          if (seleccionada) {
            fallas.add({'categoria': categoria, 'falla': falla});
          }
        });
      });

      // Añadir log para depurar el valor de _selectedCentroCosto en el catch
      print('Valor de _selectedCentroCosto en catch: $_selectedCentroCosto');

      final registration = TabletRegistration(
        activo: _activoController.text,
        inventario: _inventarioController.text,
        numeroSerie: _serieController.text,
        versionAndroid: _selectedAndroid,
        anioAdquisicion: _selectedAnio,
        agencia: _selectedAgencia,
        proceso: _selectedProceso,
        centroCosto: _selectedCentroCosto,
        rpeTrabajador: _trabajadorAsignado?['rpe'],
        marcaChip: AppStrings.fixedChipBrand,
        numeroSerieChip: _chipSerieController.text.isEmpty
            ? null
            : _chipSerieController.text,
        ubicacionRegistro: _currentLocation != null
            ? '${_currentLocation!.latitude},${_currentLocation!.longitude}'
            : null,
        fotoPaths: fotoPaths,
        firmaPath: firmaPath,
        fallas: fallas,
        asignadaPor: widget.userData?['rpe'] ?? 'UNKNOWN',
        timestamp: DateTime.now(),
      );

      await _syncService.saveRegistrationLocally(registration);
      _showSnackBar(
        'Error al enviar registro: ${e.toString().replaceAll('Exception: ', '')}. Guardado localmente.',
        isError: true,
      );
      _resetForm();
      await _updatePendingCount();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _activoController.clear();
      _inventarioController.clear();
      _serieController.clear();
      _chipSerieController.clear();
      _selectedAndroid = null;
      _selectedAnio = null;
      _selectedAgencia = null;
      _selectedProceso = null;
      _selectedCentroCosto = null;
      _trabajadorAsignado = null;
      _trabajadorController.clear();
      _fotos.fillRange(0, 4, null);
      _selectedCategoriaFalla = null;
      _signatureController.clear();
      _isSignatureConfirmed = false;
      _currentLocation = null;
      _isLocationLoading = false;
    });
    _getCurrentLocation();
  }

  Future<void> _buscarTrabajador() async {
    if (_trabajadorController.text.isEmpty) {
      _showSnackBar(AppStrings.emptyRpeError, isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final trabajador = await TrabajadoresApi.buscarPorRpe(
        _trabajadorController.text,
      );
      setState(() {
        _trabajadorAsignado = Map<String, dynamic>.from(trabajador);
        _trabajadorAsignado!['foto_perfil'] ??= 'default.jpg';
      });
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
      setState(() => _trabajadorAsignado = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearSignature() {
    setState(() {
      _signatureController.clear();
      _isSignatureConfirmed = false;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? AppColors.errorColor : AppColors.cfeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          AppStrings.registrationTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.cfeDarkGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: _pendingCountNotifier,
            builder: (context, count, child) {
              if (count > 0) {
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingRegistrationsScreen(),
                      ),
                    );
                    await _updatePendingCount();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.cfeGreen,
                            AppColors.cfeDarkGreen,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cfeGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_top,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$count Pendiente${count > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          TabletRegistrationContent(
            formKey: _formKey,
            activoController: _activoController,
            inventarioController: _inventarioController,
            serieController: _serieController,
            trabajadorController: _trabajadorController,
            chipSerieController: _chipSerieController,
            selectedAndroid: _selectedAndroid,
            selectedAnio: _selectedAnio,
            selectedAgencia: _selectedAgencia,
            selectedProceso: _selectedProceso,
            selectedCentroCosto: _selectedCentroCosto,
            trabajadorAsignado: _trabajadorAsignado,
            fotos: _fotos,
            selectedCategoriaFalla: _selectedCategoriaFalla,
            fallasPorCategoria: _fallasPorCategoria,
            signatureController: _signatureController,
            isSignatureConfirmed: _isSignatureConfirmed,
            onAndroidChanged: (val) => setState(() => _selectedAndroid = val),
            onAnioChanged: (val) => setState(() => _selectedAnio = val),
            onAgenciaChanged: (val) => setState(() => _selectedAgencia = val),
            onProcesoChanged: (val) => setState(() => _selectedProceso = val),
            onCentroCostoChanged: (val) => setState(() => _selectedCentroCosto = val),
            onTakePhoto: _tomarFoto,
            onSearchWorker: _buscarTrabajador,
            onCategoriaFallaChanged: (val) =>
                setState(() => _selectedCategoriaFalla = val),
            onFallaChanged: (falla, value) => setState(
              () => _fallasPorCategoria[_selectedCategoriaFalla]![falla] = value,
            ),
            onRegister: _registrarTableta,
            onClearSignature: _clearSignature,
            onConfirmSignature: _confirmSignature,
            currentLocation: _currentLocation,
            onRetryLocation: _retryLocation,
            isLocationLoading: _isLocationLoading,
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.cfeGreen),
              ),
            ),
        ],
      ),
    );
  }
}