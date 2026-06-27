import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class BackendService {
  final String _baseUrl = 'http://127.0.0.1:5000'; // change to your IP if using real device

  Future<String> sendVideoForTranslation(File videoFile) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/translate'));
    request.files.add(
      await http.MultipartFile.fromPath('video', videoFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['translation'] ?? 'No result';
    } else {
      throw Exception('Failed to get translation: ${response.statusCode}');
    }
  }
}
