import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String _baseUrl =
      'https://sistemascfe.com/cfe-api/'; // Para emulador Android
  // static const String _baseUrl = 'http://localhost/cfe-api'; // Para iOS/real device

  Future<Map<String, dynamic>> login(
    String identifier,
    String password, {
    bool isEmail = false,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/login.php');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              if (!isEmail)
                'rpe': identifier.trim(), // Envía rpe si no es email
              if (isEmail)
                'correo':
                    identifier.trim(), // Envía correo (no email) si es email
              'password': password.trim(),
            }),
          )
          .timeout(Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  Future<String> obtenerFotoPerfil(String rpe) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/perfiles/get.php?rpe=$rpe'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['foto'];
      }
      return 'default.jpg';
    } catch (e) {
      return 'default.jpg';
    }
  }

  // Método para probar la conexión
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/test/db_test.php'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // En tu archivo auth_api.dart, agrega:
  Future<Map<String, dynamic>> obtenerDatosRegistrador(String rpe) async {
    final url = Uri.parse('$_baseUrl/auth/perfil.php?rpe=$rpe');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'];
      } else {
        throw Exception(responseData['message'] ?? 'Error al obtener datos');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  //metodo para traer los datos del registrador:
  // Método para obtener el historial de asignaciones (NUEVA IMPLEMENTACIÓN)
  Future<List<dynamic>> obtenerHistorialAsignaciones(
    String rpeRegistrador,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/api/tabletas/historial.php?asignada_por=$rpeRegistrador',
    );

    try {
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      // Verificación adicional para respuestas HTML inesperadas
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        throw Exception('El servidor respondió con HTML en lugar de JSON');
      }

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'];
      } else {
        throw Exception(
          responseData['message'] ?? 'Error al obtener historial',
        );
      }
    } on FormatException catch (e) {
      throw Exception('Formato de respuesta inválido: ${e.message}');
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
