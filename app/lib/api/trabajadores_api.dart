import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrabajadoresApi {
  static const String _baseUrl = 'https://sistemascfe.com/cfe-api/api/trabajadores/';

  static Future<Map<String, dynamic>> buscarPorRpe(String rpe) async {
    try {
      // Obtener token JWT de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      final response = await http.get(
        Uri.parse('${_baseUrl}buscar.php?rpe=$rpe'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Trabajador no encontrado');
      } else {
        throw Exception('Error al buscar trabajador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}