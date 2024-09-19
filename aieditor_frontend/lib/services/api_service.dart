import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<String?> processImage({
    required File image,
    int height = 1024,
    int width = 1024,
    int steps = 8,
    double scales = 3.5,
    required String prompt,
    int seed = 3413,
  }) async {
    var uri = Uri.parse('$baseUrl/process_image');
    var request = http.MultipartRequest('POST', uri)
      ..fields['height'] = height.toString()
      ..fields['width'] = width.toString()
      ..fields['steps'] = steps.toString()
      ..fields['scales'] = scales.toString()
      ..fields['prompt'] = prompt
      ..fields['seed'] = seed.toString()
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      var data = json.decode(respStr);
      return data['filepath'];
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> removeObject({required File image}) async {
    var uri = Uri.parse('$baseUrl/remove_object');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      var data = json.decode(respStr);
      return data['filepath'];
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }
}