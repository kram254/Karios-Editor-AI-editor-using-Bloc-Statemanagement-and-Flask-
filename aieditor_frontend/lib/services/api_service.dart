import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<String?> processImage({
    required String prompt,
  }) async {
    var uri = Uri.parse('$baseUrl/process_image');
    var request = http.MultipartRequest('POST', uri)
      ..fields['prompt'] = prompt;

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












































// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   final String baseUrl;

//   ApiService({required this.baseUrl});

//   Future<String?> processImage({
//     required String prompt,
//   }) async {
//     var uri = Uri.parse('$baseUrl/process_image');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['prompt'] = prompt;

//     var response = await request.send();

//     if (response.statusCode == 200) {
//       var respStr = await response.stream.bytesToString();
//       var data = json.decode(respStr);
//       return data['filepath'];
//     } else {
//       print('Error: ${response.statusCode}');
//       return null;
//     }
//   }

//   Future<String?> removeObject({required File image}) async {
//     var uri = Uri.parse('$baseUrl/remove_object');
//     var request = http.MultipartRequest('POST', uri)
//       ..files.add(await http.MultipartFile.fromPath('file', image.path));

//     var response = await request.send();

//     if (response.statusCode == 200) {
//       var respStr = await response.stream.bytesToString();
//       var data = json.decode(respStr);
//       return data['filepath'];
//     } else {
//       print('Error: ${response.statusCode}');
//       return null;
//     }
//   }
// }