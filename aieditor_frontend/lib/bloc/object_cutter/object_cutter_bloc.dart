// aieditor_frontend/lib/bloc/object_cutter/object_cutter_bloc.dart
import 'package:bloc/bloc.dart';
import '../../services/api_service.dart';
import 'object_cutter_event.dart';
import 'object_cutter_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ObjectCutterBloc extends Bloc<ObjectCutterEvent, ObjectCutterState> {
  final ApiService apiService;
  String? _uploadedImageUrl;

  ObjectCutterBloc({required this.apiService}) : super(ObjectCutterInitial()) {
    on<UploadImageEvent>(_onUploadImage);
    on<ApplyPromptEvent>(_onApplyPrompt);
  }

  Future<void> _onUploadImage(
      UploadImageEvent event, Emitter<ObjectCutterState> emit) async {
    emit(ObjectCutterLoading());
    try {
      print('Uploading image: ${event.imageFile.path}');
      var response = await apiService.uploadImage(
        imageFile: event.imageFile,
        prompt: '', // Initial upload without prompt
      );

      print('Upload response: ${json.encode(response)}');

      if (response != null && response['original_image'] != null) {
        _uploadedImageUrl = response['original_image'];
        print('Uploaded image URL: $_uploadedImageUrl');
        
        String? editedImageUrl = response['edited_image'];
        if (editedImageUrl != null) {
          emit(ObjectCutterSuccess(_uploadedImageUrl!, editedImageUrl));
        } else {
          emit(ObjectCutterUploaded(_uploadedImageUrl!));
        }
      } else {
        print('Upload failed. Response: $response');
        emit(ObjectCutterError(response?['error'] ?? 'Failed to upload image.'));
      }
    } catch (e) {
      print('Exception during image upload: $e');
      emit(ObjectCutterError('Failed to upload image: ${e.toString()}'));
    }
  }

  Future<void> _onApplyPrompt(
      ApplyPromptEvent event, Emitter<ObjectCutterState> emit) async {
    if (_uploadedImageUrl == null) {
      emit(ObjectCutterError('No image uploaded.'));
      return;
    }

    print('Applying prompt. Uploaded image URL: $_uploadedImageUrl');
    print('Prompt: ${event.prompt}');

    emit(ObjectCutterLoading());
    try {
      String imagePath = await _downloadImage(_uploadedImageUrl!);
      var imageFile = File(imagePath);

      print('Downloaded image path: $imagePath');

      var response = await apiService.uploadImage(
        imageFile: imageFile,
        prompt: event.prompt,
      );

      print('Apply prompt response: ${json.encode(response)}');

      if (response != null && response['edited_image'] != null) {
        emit(ObjectCutterSuccess(_uploadedImageUrl!, response['edited_image']));
      } else {
        print('Image processing failed. Response: $response');
        emit(ObjectCutterError(response?['error'] ?? 'Failed to process image.'));
      }
    } catch (e) {
      print('Exception during prompt application: $e');
      emit(ObjectCutterError('Failed to process image: ${e.toString()}'));
    }
  }

  Future<String> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/temp_image.png';
        final tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(bytes);
        return tempFilePath;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during image download: $e');
      throw Exception('Failed to download image: ${e.toString()}');
    }
  }
}



































// import 'package:bloc/bloc.dart';
// import '../../services/api_service.dart';
// import 'object_cutter_event.dart';
// import 'object_cutter_state.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class ObjectCutterBloc extends Bloc<ObjectCutterEvent, ObjectCutterState> {
//   final ApiService apiService;
//   String? _uploadedImageUrl;

//   ObjectCutterBloc({required this.apiService}) : super(ObjectCutterInitial()) {
//     on<UploadImageEvent>(_onUploadImage);
//     on<ApplyPromptEvent>(_onApplyPrompt);
//   }

//   Future<void> _onUploadImage(
//       UploadImageEvent event, Emitter<ObjectCutterState> emit) async {
//     emit(ObjectCutterLoading());
//     try {
//       // Upload the image to the backend without any prompt
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${apiService.baseUrl}/api/object_cutter'),
//       );
//       request.files.add(await http.MultipartFile.fromPath(
//         'image',
//         event.imageFile.path,
//       ));
//       // No prompt
//       request.fields['prompt'] = '';

//       var response = await request.send();

//       if (response.statusCode == 200) {
//         var respStr = await response.stream.bytesToString();
//         var data = json.decode(respStr);
//         _uploadedImageUrl = data['original_image'];
//         String? editedImageUrl = data['edited_image'];
//         if (editedImageUrl != null) {
//           emit(ObjectCutterSuccess(_uploadedImageUrl!, editedImageUrl));
//         } else {
//           emit(ObjectCutterUploaded(_uploadedImageUrl!));
//         }
//       } else {
//         var respStr = await response.stream.bytesToString();
//         var data = json.decode(respStr);
//         emit(ObjectCutterError(data['error'] ?? 'Unknown error'));
//       }
//     } catch (e) {
//       emit(ObjectCutterError(e.toString()));
//     }
//   }

//   Future<void> _onApplyPrompt(
//       ApplyPromptEvent event, Emitter<ObjectCutterState> emit) async {
//     if (_uploadedImageUrl == null) {
//       emit(ObjectCutterError('No image uploaded.'));
//       return;
//     }

//     emit(ObjectCutterLoading());
//     try {
//       // Download the uploaded image to send to the backend
//       final response = await http.get(Uri.parse(_uploadedImageUrl!));
//       if (response.statusCode != 200) {
//         emit(ObjectCutterError('Failed to download the uploaded image.'));
//         return;
//       }

//       final bytes = response.bodyBytes;
//       final tempDir = await getTemporaryDirectory();
//       final tempFilePath = '${tempDir.path}/uploaded_image.png';
//       final tempFile = File(tempFilePath);
//       await tempFile.writeAsBytes(bytes);

//       // Send prompt and image to backend
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${apiService.baseUrl}/api/object_cutter'),
//       );
//       request.files.add(await http.MultipartFile.fromPath(
//         'image',
//         tempFilePath,
//       ));
//       request.fields['prompt'] = event.prompt;

//       var responsePost = await request.send();

//       if (responsePost.statusCode == 200) {
//         var respStr = await responsePost.stream.bytesToString();
//         var data = json.decode(respStr);
//         String editedImageUrl = data['edited_image'];
//         emit(ObjectCutterSuccess(_uploadedImageUrl!, editedImageUrl));
//       } else {
//         var respStr = await responsePost.stream.bytesToString();
//         var data = json.decode(respStr);
//         emit(ObjectCutterError(data['error'] ?? 'Unknown error'));
//       }
//     } catch (e) {
//       emit(ObjectCutterError(e.toString()));
//     }
//   }
// }
































//   import 'package:bloc/bloc.dart';
//   import '../../services/api_service.dart';
// import 'object_cutter_event.dart';
//   import 'object_cutter_state.dart';
//   import 'package:http/http.dart' as http;
//   import 'dart:convert';
//   import 'dart:io';
//   import 'package:path_provider/path_provider.dart';

//   class ObjectCutterBloc extends Bloc<ObjectCutterEvent, ObjectCutterState> {
//     final ApiService apiService;
//     String? _uploadedImageUrl;

//     ObjectCutterBloc({required this.apiService}) : super(ObjectCutterInitial()) {
//       on<UploadImageEvent>(_onUploadImage);
//       on<ApplyPromptEvent>(_onApplyPrompt);
//     }

//     Future<void> _onUploadImage(
//         UploadImageEvent event, Emitter<ObjectCutterState> emit) async {
//       emit(ObjectCutterLoading());
//       try {
//         // Upload the image to the backend
//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse('${apiService.baseUrl}/api/object_cutter'),
//         );
//         request.files.add(await http.MultipartFile.fromPath(
//           'image',
//           event.imageFile.path,
//         ));
//         // Initially, no prompt
//         request.fields['prompt'] = '';

//         var response = await request.send();

//         if (response.statusCode == 200) {
//           var respStr = await response.stream.bytesToString();
//           var data = json.decode(respStr);
//           _uploadedImageUrl = data['original_image'];
//           String editedImageUrl = data['edited_image'];
//           emit(ObjectCutterSuccess(_uploadedImageUrl!, editedImageUrl));
//         } else {
//           var respStr = await response.stream.bytesToString();
//           var data = json.decode(respStr);
//           emit(ObjectCutterError(data['error'] ?? 'Unknown error'));
//         }
//       } catch (e) {
//         emit(ObjectCutterError(e.toString()));
//       }
//     }

//     Future<void> _onApplyPrompt(
//         ApplyPromptEvent event, Emitter<ObjectCutterState> emit) async {
//       if (_uploadedImageUrl == null) {
//         emit(ObjectCutterError('No image uploaded.'));
//         return;
//       }

//       emit(ObjectCutterLoading());
//       try {
//         // Download the uploaded image to send to the backend
//         final response = await http.get(Uri.parse(_uploadedImageUrl!));
//         if (response.statusCode != 200) {
//           emit(ObjectCutterError('Failed to download the uploaded image.'));
//           return;
//         }

//         final bytes = response.bodyBytes;
//         final tempDir = await getTemporaryDirectory();
//         final tempFilePath = '${tempDir.path}/uploaded_image.png';
//         final tempFile = File(tempFilePath);
//         await tempFile.writeAsBytes(bytes);

//         // Send prompt and image to backend
//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse('${apiService.baseUrl}/api/object_cutter'),
//         );
//         request.files.add(await http.MultipartFile.fromPath(
//           'image',
//           tempFilePath,
//         ));
//         request.fields['prompt'] = event.prompt;

//         var responsePost = await request.send();

//         if (responsePost.statusCode == 200) {
//           var respStr = await responsePost.stream.bytesToString();
//           var data = json.decode(respStr);
//           String editedImageUrl = data['edited_image'];
//           emit(ObjectCutterSuccess(_uploadedImageUrl!, editedImageUrl));
//         } else {
//           var respStr = await responsePost.stream.bytesToString();
//           var data = json.decode(respStr);
//           emit(ObjectCutterError(data['error'] ?? 'Unknown error'));
//         }
//       } catch (e) {
//         emit(ObjectCutterError(e.toString()));
//       }
//     }
//   }