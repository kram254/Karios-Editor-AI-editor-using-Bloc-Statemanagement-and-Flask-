import 'package:bloc/bloc.dart';
import 'image_generation_event.dart';
import 'image_generation_state.dart';
import '../../services/api_service.dart';

class ImageGenerationBloc extends Bloc<ImageGenerationEvent, ImageGenerationState> {
  final ApiService apiService;
  List<String> imageList = [];

  ImageGenerationBloc({required this.apiService}) : super(ImageGenerationInitial()) {
    on<LoadImagesEvent>((event, emit) async {
      emit(ImagesLoadingState());
      try {
        final fetchedImages = await apiService.fetchGeneratedImages();
        if (fetchedImages != null) {
          imageList = fetchedImages;
          emit(ImagesLoadedState(imageList));
        } else {
          emit(ImageGenerationErrorState('Failed to fetch images.'));
        }
      } catch (e) {
        emit(ImageGenerationErrorState(e.toString()));
      }
    });

    on<GenerateImageEvent>((event, emit) async {
      emit(ImageProcessingState());
      try {
        final generatedPath = await apiService.processImage(
          prompt: event.prompt,
        );
        if (generatedPath != null) {
          // Add the new image to the list
          imageList.add(generatedPath);
          // Emit the updated list
          emit(ImagesLoadedState(List.from(imageList)));
        } else {
          emit(const ImageGenerationErrorState('Failed to generate image.'));
        }
      } catch (e) {
        emit(ImageGenerationErrorState(e.toString()));
      }
    });
  }
}