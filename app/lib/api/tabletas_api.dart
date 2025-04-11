import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TabletasApi {
  static const String _baseUrl = 'https://sistemascfe.com/cfe-api/api/tabletas/';

  static Future<bool> registrarTableta(Map<String, dynamic> datos) async {
    try {
      print('Enviando a registrar.php: $datos');
      final response = await http.post(
        Uri.parse('${_baseUrl}registrar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );

      print('Respuesta del servidor: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al registrar: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  static Future<int> registrarHistorial({
    required String activo,
    required String rpeTrabajador,
    required String tipoAsignacion,
    required String asignadaPor,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('${_baseUrl}registrar_historial.php'));
      request.fields.addAll({
        'activo': activo,
        'rpe_trabajador': rpeTrabajador,
        'tipo_asignacion': tipoAsignacion,
        'asignada_por': asignadaPor,
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('Response from registrarHistorial: Status ${response.statusCode}, Body: $responseBody');
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        if (responseData['id'] != null) {
          return int.parse(responseData['id'].toString());
        } else {
          throw Exception('El servidor no devolvió el ID del historial');
        }
      } else {
        throw Exception('Error en historial (${response.statusCode}): $responseBody');
      }
    } catch (e) {
      throw Exception('Error al registrar historial: ${e.toString()}');
    }
  }

  static Future<void> registrarFallaHistorial({
    required int historialId,
    required String categoria,
    required String falla,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}registrar_falla_historial.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'historial_id': historialId,
          'categoria': categoria,
          'falla': falla,
        }),
      );

      print('Respuesta de registrarFallaHistorial: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al registrar falla: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al registrar falla: ${e.toString()}');
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

      print('Respuesta de subirFoto: Status ${response.statusCode}, Body: $responseBody');

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al subir foto: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  static Future<List<dynamic>> obtenerHistorialAsignaciones(String rpeRegistrador) async {
    final url = Uri.parse('${_baseUrl}historial.php?asignada_por=$rpeRegistrador');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        return [];
      }

      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (responseData['data'] == null || responseData['data'].isEmpty) {
        return [];
      }

      return responseData['data'];
    } on FormatException {
      throw Exception('Error al procesar los datos del servidor');
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}