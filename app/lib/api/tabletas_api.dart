import 'dart:convert';
import 'dart:io'; // Necesario para la clase File
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Necesario para MediaType

class TabletasApi {
  static const String _baseUrl = 'https://sistemascfe.com/cfe-api/api/tabletas/';

  static Future<bool> registrarTableta(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}registrar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Error al registrar: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  static Future<bool> registrarHistorial({
    required String activo,
    required String rpeTrabajador,
    required String tipoAsignacion, // Nuevo parámetro requerido
    required String asignadaPor, // Nuevo parámetro requerido
    String? observaciones,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_baseUrl}registrar_historial.php'),
      );

      // Campos obligatorios
      request.fields.addAll({
        'activo': activo,
        'rpe_trabajador': rpeTrabajador,
        'tipo_asignacion': tipoAsignacion,
        'asignada_por': asignadaPor,
      });

      // Campo opcional
      if (observaciones != null && observaciones.isNotEmpty) {
        request.fields['observaciones'] = observaciones;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Error en historial (${response.statusCode}): $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Error al registrar historial: ${e.toString()}');
    }
  }

  static Future<bool> subirFoto({
    required String tabletaId,
    required File foto,
    required int fotoIndex,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_baseUrl}subir_fotos.php'),
      );

      request.fields['tableta_id'] = tabletaId;
      request.fields['foto_index'] = fotoIndex.toString();
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Error al subir foto: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  Future<List<dynamic>> obtenerHistorialAsignaciones(
    String rpeRegistrador,
  ) async {
    final url = Uri.parse(
      'https://sistemascfe.com/cfe-api/api/tabletas/historial.php?asignada_por=$rpeRegistrador',
    );

    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      // Caso especial: Respuesta 404 (no encontrado)
      if (response.statusCode == 404) {
        return []; // Retorna lista vacía, NO es un error
      }

      // Otros errores HTTP
      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      // Si la API retorna 'data' vacía o null
      if (responseData['data'] == null || responseData['data'].isEmpty) {
        return [];
      }

      return responseData['data'];
    } on FormatException {
      throw Exception('Error al procesar los datos del servidor');
    } catch (e) {
      throw Exception(
        'Error de conexión: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }
}
