import 'package:bloc/bloc.dart';
import 'image_generation_event.dart';
import 'image_generation_state.dart';
import '../../services/api_service.dart';

class ImageGenerationBloc extends Bloc<ImageGenerationEvent, ImageGenerationState> {
  final ApiService apiService;

  ImageGenerationBloc({required this.apiService}) : super(ImageGenerationInitial()) {
    on<GenerateImageEvent>((event, emit) async {
      emit(ImageProcessingState());
      try {
        final generatedPath = await apiService.processImage(
          prompt: event.prompt,
        );
        if (generatedPath != null) {
          emit(ImageGeneratedState(generatedPath));
        } else {
          emit(const ImageGenerationErrorState('Failed to generate image.'));
        }
      } catch (e) {
        emit(ImageGenerationErrorState(e.toString()));
      }
    });
  }
}

























































// import 'dart:io';
// import 'package:bloc/bloc.dart';
// import 'image_generation_event.dart';
// import 'image_generation_state.dart';
// import '../../services/api_service.dart';

// class ImageGenerationBloc extends Bloc<ImageGenerationEvent, ImageGenerationState> {
//   final ApiService apiService;

//   ImageGenerationBloc({required this.apiService}) : super(ImageGenerationInitial()) {
//     on<SelectImageEvent>((event, emit) {
//       emit(ImageSelectedState(event.image.path));
//     });

//     on<GenerateImageEvent>((event, emit) async {
//       final currentState = state;
//       if (currentState is ImageSelectedState) {
//         emit(ImageProcessingState());
//         try {
//           final generatedPath = await apiService.processImage(
//             image: File(currentState.imagePath),
//             prompt: event.prompt,
//           );
//           if (generatedPath != null) {
//             emit(ImageGeneratedState(generatedPath));
//           } else {
//             emit(const ImageGenerationErrorState('Failed to generate image.'));
//           }
//         } catch (e) {
//           emit(ImageGenerationErrorState(e.toString()));
//         }
//       }
//     });
//   }
// }