import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:signature/signature.dart';
import 'package:latlong2/latlong.dart';
import '../api/trabajadores_api.dart';
import '../api/tabletas_api.dart';
import '../constants.dart';
import 'tablet_registration_content.dart';

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
  bool _isLocationLoading = true; // Nuevo estado para manejar carga inicial

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtener ubicación al iniciar
  }

  @override
  void dispose() {
    _activoController.dispose();
    _inventarioController.dispose();
    _serieController.dispose();
    _trabajadorController.dispose();
    _chipSerieController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true); // Indicar que está cargando
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

      // Intentar obtener la última ubicación conocida para mostrar algo rápido
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && mounted) {
        setState(() {
          _currentLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
          _isLocationLoading = false;
        });
      }

      // Obtener ubicación precisa en segundo plano
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5), // Reducido para mayor rapidez
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
    setState(() => _isLoading = true);
    _getCurrentLocation().then((_) {
      if (mounted) setState(() => _isLoading = false);
    });
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
        setState(() => _fotos[index] = File(image.path));
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
        final tempDir = await Directory.systemTemp.createTemp();
        final signatureFile = File('${tempDir.path}/signature.png');
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
      final datosTableta = {
        'activo': _activoController.text,
        'inventario': _inventarioController.text,
        'numero_serie': _serieController.text,
        'version_android': _selectedAndroid,
        'anio_adquisicion': _selectedAnio,
        'agencia': _selectedAgencia,
        'proceso': _selectedProceso,
        'rpe_trabajador': _trabajadorAsignado?['rpe'],
        'marca_chip': AppStrings.fixedChipBrand,
        'numero_serie_chip':
            _chipSerieController.text.isEmpty ? null : _chipSerieController.text,
        if (_currentLocation != null)
          'ubicacion_registro':
              '${_currentLocation!.latitude},${_currentLocation!.longitude}',
      };

      final registroExitoso = await TabletasApi.registrarTableta(datosTableta);
      if (!registroExitoso) throw Exception('Error al registrar tableta');

      if (_trabajadorAsignado != null) {
        String? firmaRuta;
        final signatureFile = await _saveSignature();
        if (signatureFile != null) {
          firmaRuta =
              'firmas/${_activoController.text}_${_trabajadorAsignado!['rpe']}.png';
          final firmaSubida = await TabletasApi.subirFirma(
            tabletaId: _activoController.text,
            rpeTrabajador: _trabajadorAsignado!['rpe'],
            firma: signatureFile,
          );
          if (!firmaSubida) {
            _showSnackBar(AppStrings.signatureUploadError, isError: true);
          }
        }

        final historialData = {
          'activo': _activoController.text,
          'rpe_trabajador': _trabajadorAsignado!['rpe'],
          'tipo_asignacion': 'Asignación inicial',
          'asignada_por': widget.userData?['rpe'] ?? 'UNKNOWN',
          'firma_ruta': firmaRuta,
        };
        final historialId = await TabletasApi.registrarHistorial(
          activo: historialData['activo']!,
          rpeTrabajador: historialData['rpe_trabajador']!,
          tipoAsignacion: historialData['tipo_asignacion']!,
          asignadaPor: historialData['asignada_por']!,
          firmaRuta: historialData['firma_ruta'],
        );

        List<Map<String, String>> fallas = [];
        _fallasPorCategoria.forEach((categoria, fallasMap) {
          fallasMap.forEach((falla, seleccionada) {
            if (seleccionada) {
              fallas.add({'categoria': categoria, 'falla': falla});
            }
          });
        });

        if (fallas.isNotEmpty) {
          for (var falla in fallas) {
            await TabletasApi.registrarFallaHistorial(
              historialId: historialId,
              categoria: falla['categoria']!,
              falla: falla['falla']!,
            );
          }
        }
      }

      bool todasSubidas = true;
      for (int i = 0; i < _fotos.length; i++) {
        if (_fotos[i] != null) {
          try {
            final fotoSubida = await TabletasApi.subirFoto(
              tabletaId: _activoController.text,
              foto: File(_fotos[i]!.path),
              fotoIndex: i + 1,
            );
            if (!fotoSubida) todasSubidas = false;
          } catch (e) {
            todasSubidas = false;
          }
        }
      }

      if (todasSubidas) {
        _showSnackBar(AppStrings.registrationSuccess);
        _resetForm();
      } else {
        _showSnackBar(AppStrings.registrationPartialSuccess, isError: true);
      }
    } catch (e) {
      _showSnackBar(
        AppStrings.registrationError.replaceFirst(
          '%s',
          e.toString().replaceAll('Exception: ', ''),
        ),
        isError: true,
      );
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
      _trabajadorAsignado = null;
      _trabajadorController.clear();
      _fotos.fillRange(0, 4, null);
      _selectedCategoriaFalla = null;
      _signatureController.clear();
      _isSignatureConfirmed = false;
      _currentLocation = null;
      _isLocationLoading = true;
    });
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
            isLocationLoading: _isLocationLoading, // Pasar el estado de carga
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