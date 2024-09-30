  import 'package:bloc/bloc.dart';
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
        // Upload the image to the backend
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${apiService.baseUrl}/api/object_cutter'),
        );
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          event.imageFile.path,
        ));
        // Initially, no prompt
        request.fields['prompt'] = '';

        var response = await request.send();

        if (response.statusCode == 200) {
          var respStr = await response.stream.bytesToString();
          var data = json.decode(respStr);
          _uploadedImageUrl = data['original_image'];
          String editedImageUrl = data['edited_image'];
          emit(ObjectCutterSuccess(_uploadedImageUrl!, editedImageUrl));
        } else {
          var respStr = await response.stream.bytesToString();
          var data = json.decode(respStr);
          emit(ObjectCutterError(data['error'] ?? 'Unknown error'));
        }
      } catch (e) {
        emit(ObjectCutterError(e.toString()));
      }
    }

    Future<void> _onApplyPrompt(
        ApplyPromptEvent event, Emitter<ObjectCutterState> emit) async {
      if (_uploadedImageUrl == null) {
        emit(ObjectCutterError('No image uploaded.'));
        return;
      }

      emit(ObjectCutterLoading());
      try {
        // Download the uploaded image to send to the backend
        final response = await http.get(Uri.parse(_uploadedImageUrl!));
        if (response.statusCode != 200) {
          emit(ObjectCutterError('Failed to download the uploaded image.'));
          return;
        }

        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/uploaded_image.png';
        final tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(bytes);

        // Send prompt and image to backend
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${apiService.baseUrl}/api/object_cutter'),
        );
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          tempFilePath,
        ));
        request.fields['prompt'] = event.prompt;

        var responsePost = await request.send();

        if (responsePost.statusCode == 200) {
          var respStr = await responsePost.stream.bytesToString();
          var data = json.decode(respStr);
          String editedImageUrl = data['edited_image'];
          emit(ObjectCutterSuccess(_uploadedImageUrl!, editedImageUrl));
        } else {
          var respStr = await responsePost.stream.bytesToString();
          var data = json.decode(respStr);
          emit(ObjectCutterError(data['error'] ?? 'Unknown error'));
        }
      } catch (e) {
        emit(ObjectCutterError(e.toString()));
      }
    }
  }