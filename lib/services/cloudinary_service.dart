import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// Datos públicos de Cloudinary. El preset es de tipo "Unsigned" y define
// la carpeta de destino (mis_mascotas).
// NUNCA poner aquí el API Key Secret.
const cloudinaryCloudName = 'coysyymi';
const cloudinaryUploadPreset = 'mascotas_unsigned';

/// Sube imágenes a Cloudinary con una subida sin firma (unsigned upload).
class CloudinaryService {
  /// Sube la imagen y devuelve su URL segura (https), que luego se guarda en Firestore.
  Future<String> subirImagen(Uint8List bytes, String nombreArchivo) async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: nombreArchivo));

    final response = await http.Response.fromStream(await request.send());
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final mensaje = (body['error'] as Map<String, dynamic>?)?['message'];
      throw Exception('Cloudinary rechazó la imagen: ${mensaje ?? response.statusCode}');
    }
    return body['secure_url'] as String;
  }
}
