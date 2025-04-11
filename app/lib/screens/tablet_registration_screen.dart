import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/trabajadores_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/tabletas_api.dart';
import 'package:geolocator/geolocator.dart';

class TabletRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const TabletRegistrationScreen({super.key, this.userData});

  @override
  State<TabletRegistrationScreen> createState() =>
      _TabletRegistrationScreenState();
}

class _TabletRegistrationScreenState extends State<TabletRegistrationScreen> {
  static const Color cfeGreen = Color(0xFF009156);
  static const Color cfeDarkGreen = Color(0xFF006341);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFD32F2F);

  final _formKey = GlobalKey<FormState>();
  final _activoController = TextEditingController();
  final _inventarioController = TextEditingController();
  final _serieController = TextEditingController();
  final _trabajadorController = TextEditingController();
  final _chipSerieController =
      TextEditingController(); // Controlador para número de serie del chip

  final String marcaFija = 'NEWLAND';
  final String modeloFijo = 'NLS-NFT10';

  String? _selectedAndroid;
  String? _selectedAnio;
  String? _selectedAgencia;
  String? _selectedProceso;
  Map<String, dynamic>? _trabajadorAsignado;
  bool _isLoading = false;
  final List<File?> _fotos = List.filled(4, null);

  // Mapa para las categorías de fallas y sus opciones
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

  String? _selectedCategoriaFalla; // Categoría seleccionada en el dropdown

  final _androidOptions = const ['8.1', '11'];
  final _anioOptions = List.generate(6, (index) => (2020 + index).toString());
  final _agenciaOptions = const [
    'EL TREINTA',
    'RENACIMIENTO',
    'SUBESTACIONES RENACIMIENTO',
    'GARITA',
    'CUAUHTEMOC',
    'VISTA ALEGRE',
    'EJIDO',
    'OFICINAS DE ZONA',
    'SUBESTACIONES ACAPULCO COSTA AZUL',
    'DIAMANTE - AMATES',
    'RENACIMIENTO SUR',
    'SAN MARCOS',
    'SAN LUIS ACATLAN',
    'OMETEPEC',
  ];
  final _procesoOptions = const [
    'COMERCIAL',
    'ISC',
    'DISTRIBUCION',
    'MEDICION',
    'ADMINISTRACION',
    'TICS',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _activoController.dispose();
    _inventarioController.dispose();
    _serieController.dispose();
    _trabajadorController.dispose();
    _chipSerieController.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (image != null) setState(() => _fotos[index] = File(image.path));
    } catch (e) {
      _showSnackBar('Error al tomar foto', isError: true);
    }
  }

  Future<String?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar(
          'Por favor, activa los servicios de ubicación',
          isError: true,
        );
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Permiso de ubicación denegado', isError: true);
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
          'Permiso de ubicación denegado permanentemente',
          isError: true,
        );
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return '${position.latitude}, ${position.longitude}';
    } catch (e) {
      print('Error al obtener ubicación: $e');
      _showSnackBar('Error al obtener la ubicación', isError: true);
      return null;
    }
  }

  Future<void> _registrarTableta() async {
    print('Iniciando registro...');
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      print('Validación del formulario falló');
      _showSnackBar(
        'Por favor, corrige los errores en el formulario',
        isError: true,
      );
      return;
    }
    if (_fotos.where((foto) => foto == null).isNotEmpty) {
      print(
        'Faltan fotos: ${_fotos.map((f) => f == null ? "null" : "ok").toList()}',
      );
      _showSnackBar('Debe tomar las 4 fotos de evidencia', isError: true);
      return;
    }
    if (_trabajadorController.text.isNotEmpty && _trabajadorAsignado == null) {
      print('RPE ingresado pero no asignado: ${_trabajadorController.text}');
      _showSnackBar('Verifique el RPE del trabajador', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? ubicacionRegistro = await _getCurrentLocation();
      if (ubicacionRegistro == null) {
        setState(() => _isLoading = false);
        return;
      }

      final datosTableta = {
        'activo': _activoController.text,
        'inventario': _inventarioController.text,
        'numero_serie': _serieController.text,
        'version_android': _selectedAndroid,
        'anio_adquisicion': _selectedAnio,
        'agencia': _selectedAgencia,
        'proceso': _selectedProceso,
        'rpe_trabajador': _trabajadorAsignado?['rpe'],
        'ubicacion_registro': ubicacionRegistro,
        'marca_chip': 'Telcel',
        'numero_serie_chip':
            _chipSerieController.text.isEmpty
                ? null
                : _chipSerieController.text,
      };

      print('Datos preparados para enviar: $datosTableta');

      final registroExitoso = await TabletasApi.registrarTableta(datosTableta);

      print('Respuesta de registrarTableta: $registroExitoso');

      if (!registroExitoso) {
        throw Exception('Error al registrar tableta');
      }

      if (_trabajadorAsignado != null) {
        try {
          final historialData = {
            'activo': _activoController.text,
            'rpe_trabajador': _trabajadorAsignado!['rpe'],
            'tipo_asignacion': 'Asignación inicial',
            'asignada_por': widget.userData?['rpe'] ?? 'UNKNOWN',
          };
          print('Datos para historial: $historialData');

          final historialId = await TabletasApi.registrarHistorial(
            activo: historialData['activo']!,
            rpeTrabajador: historialData['rpe_trabajador']!,
            tipoAsignacion: historialData['tipo_asignacion']!,
            asignadaPor: historialData['asignada_por']!,
          );
          print('Historial registrado con ID: $historialId');

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
              print(
                'Falla registrada: ${falla['categoria']}: ${falla['falla']}',
              );
            }
          }
        } catch (e) {
          print('Error en historial: $e');
          _showSnackBar(
            'Error al registrar historial o fallas: $e',
            isError: true,
          );
        }
      }

      bool todasSubidas = true;
      for (int i = 0; i < _fotos.length; i++) {
        if (_fotos[i] != null) {
          try {
            print(
              'Subiendo foto ${i + 1} para tabletaId: ${_activoController.text}',
            );
            await TabletasApi.subirFoto(
              tabletaId: _activoController.text,
              foto: File(_fotos[i]!.path),
              fotoIndex: i + 1,
              token: widget.userData?['token'] ?? '',
            );
            print('Foto ${i + 1} subida con éxito');
          } catch (e) {
            todasSubidas = false;
            print('Error subiendo foto ${i + 1}: $e');
          }
        }
      }

      if (todasSubidas) {
        print('Registro completo exitoso');
        _showSnackBar('Registro completo exitoso');
        _resetForm();
      } else {
        print('Algunas fotos no se subieron');
        _showSnackBar(
          'Tablet registrada pero algunas fotos no se subieron',
          isError: true,
        );
      }
    } catch (e) {
      print('Error en el registro: $e');
      _showSnackBar(
        'Error en el registro: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      _fallasPorCategoria.forEach((categoria, fallasMap) {
        fallasMap.updateAll((key, value) => false);
      });
    });
  }

  Future<void> _buscarTrabajador() async {
    if (_trabajadorController.text.isEmpty) {
      _showSnackBar('Ingrese un RPE para buscar', isError: true);
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? errorColor : cfeGreen,
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Registro de Tableta',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: cfeDarkGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSection('Información Fija', _buildInfoFija()),
                const SizedBox(height: 20),
                _buildSection('Detalles', _buildDetallesForm()),
                const SizedBox(height: 20),
                _buildSection(
                  'Información del Chip',
                  _buildChipForm(),
                ), // Nuevo bloque
                const SizedBox(height: 20),
                _buildSection('Evidencia Fotográfica', _buildFotosGrid()),
                const SizedBox(height: 20),
                _buildSection('Asignación', _buildAsignacionForm()),
                const SizedBox(height: 20),
                _buildSection('Observaciones', _buildObservacionesField()),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: cfeGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cfeDarkGreen,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        ),
      ],
    );
  }

  Widget _buildInfoFija() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem('Marca', marcaFija),
        _buildInfoItem('Modelo', modeloFijo),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDetallesForm() {
    return Column(
      children: [
        _buildTextField(_activoController, 'Número de Activo', required: true),
        const SizedBox(height: 16),
        _buildTextField(
          _inventarioController,
          'Número de Inventario',
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(_serieController, 'Número de Serie', required: true),
        const SizedBox(height: 16),
        _buildDropdown(
          'Versión Android',
          _androidOptions,
          _selectedAndroid,
          (val) => _selectedAndroid = val,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          'Año de Adquisición',
          _anioOptions,
          _selectedAnio,
          (val) => _selectedAnio = val,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          'Agencia',
          _agenciaOptions,
          _selectedAgencia,
          (val) => _selectedAgencia = val,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          'Proceso',
          _procesoOptions,
          _selectedProceso,
          (val) => _selectedProceso = val,
          required: true,
        ),
      ],
    );
  }

  Widget _buildChipForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Marca del Chip:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Telcel',
              style: const TextStyle(
                color: cfeDarkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          _chipSerieController,
          'Número de Serie del Chip',
          required: false,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cfeGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      inputFormatters:
          label == 'Número de Activo'
              ? [LengthLimitingTextInputFormatter(8)]
              : null,
      autovalidateMode:
          label == 'Número de Activo'
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
      validator: (value) {
        if (required && (value?.isEmpty ?? true)) {
          print('$label vacío: $value');
          return 'Requerido';
        }
        if (label == 'Número de Activo' && value!.length != 8) {
          print('Número de Activo inválido: $value (longitud ${value.length})');
          return 'Debe tener exactamente 8 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cfeGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
              .toList(),
      onChanged: (val) => setState(() => onChanged(val)),
      validator:
          required ? (value) => value == null ? 'Requerido' : null : null,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildFotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder:
          (context, index) => GestureDetector(
            onTap: () => _tomarFoto(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1.5),
                image:
                    _fotos[index] != null
                        ? DecorationImage(
                          image: FileImage(_fotos[index]!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _fotos[index] == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Foto ${index + 1}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                      : null,
            ),
          ),
    );
  }

  Widget _buildAsignacionForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _trabajadorController,
                'RPE del Trabajador',
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _buscarTrabajador,
              style: ElevatedButton.styleFrom(
                backgroundColor: cfeGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Buscar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        if (_trabajadorAsignado != null) ...[
          const SizedBox(height: 16),
          _buildTrabajadorInfo(),
        ],
      ],
    );
  }

  Widget _buildTrabajadorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cfeGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cfeGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: CachedNetworkImageProvider(
              'https://sistemascfe.com/cfe-api/uploads/perfiles/${_trabajadorAsignado!['foto_perfil']}',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _trabajadorAsignado!['nombre'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RPE: ${_trabajadorAsignado!['rpe']}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  _trabajadorAsignado!['cargo'],
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  _trabajadorAsignado!['agencia'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _registrarTableta,
      style: ElevatedButton.styleFrom(
        backgroundColor: cfeGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 0),
        elevation: 0,
      ),
      child: const Text(
        'Registrar Tableta',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildObservacionesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategoriaFalla,
          decoration: InputDecoration(
            labelText: 'Categoría de falla',
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: cfeGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items:
              _fallasPorCategoria.keys
                  .map(
                    (categoria) => DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedCategoriaFalla = value),
          hint: const Text('Seleccione una categoría'),
        ),
        if (_selectedCategoriaFalla != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Fallas específicas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cfeDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          ..._fallasPorCategoria[_selectedCategoriaFalla]!.entries.map((entry) {
            final falla = entry.key;
            final seleccionada = entry.value;
            return CheckboxListTile(
              title: Text(falla, style: const TextStyle(fontSize: 14)),
              value: seleccionada,
              onChanged: (bool? value) {
                setState(() {
                  _fallasPorCategoria[_selectedCategoriaFalla]![falla] =
                      value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              dense: true,
            );
          }).toList(),
        ],
      ],
    );
  }
}
