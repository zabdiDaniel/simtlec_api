import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FotosApi {
  static const String baseUrl = 'https://sistemascfe.com/cfe-api/api/tabletas';

  static Future<bool> subirFoto({
    required String tabletaId,
    required File foto,
    required int fotoIndex,
    required String token,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/subir_fotos.php'),
      );

      // Agregar campos
      request.fields['tableta_id'] = tabletaId;
      request.fields['foto_index'] = fotoIndex.toString();

      // Agregar archivo
      request.files.add(await http.MultipartFile.fromPath(
        'foto',
        foto.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error al subir foto: ${response.statusCode} - $responseBody');
        return false;
      }
    } catch (e) {
      print('Excepción al subir foto: $e');
      return false;
    }
  }
}