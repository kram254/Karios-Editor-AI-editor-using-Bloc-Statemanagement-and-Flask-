import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});



  Future<String?> processImage({
    required String prompt,
    double height = 1024,
    double width = 1024,
    double steps = 8,
    double scales = 3.5,
    double seed = 3413,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/process_image');
      var request = http.MultipartRequest('POST', uri)
        ..fields['prompt'] = prompt
        ..fields['height'] = height.toString()
        ..fields['width'] = width.toString()
        ..fields['steps'] = steps.toString()
        ..fields['scales'] = scales.toString()
        ..fields['seed'] = seed.toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var data = json.decode(respStr);
        return data['filepath'];
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in processImage: $e');
      return null;
    }
  }




   Future<Map<String, dynamic>?> postMultipart(String endpoint, Map<String, String> fields, File file) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      var request = http.MultipartRequest('POST', uri)
        ..fields.addAll(fields)
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        return json.decode(respStr);
      } else {
        var respStr = await response.stream.bytesToString();
        return {'error': json.decode(respStr)['error'] ?? 'Unknown error'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }




 

  Future<List<String>?> fetchGeneratedImages() async {
    try {
      var uri = Uri.parse('$baseUrl/list_images');
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<String> images = List<String>.from(data['images']);
        return images;
      } else {
        print('Error fetching images: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in fetchGeneratedImages: $e');
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



























