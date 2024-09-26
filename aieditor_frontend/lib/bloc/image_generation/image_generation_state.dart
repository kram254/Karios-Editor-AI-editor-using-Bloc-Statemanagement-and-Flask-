import 'package:equatable/equatable.dart';

abstract class ImageGenerationState extends Equatable {
  const ImageGenerationState();

  @override
  List<Object?> get props => [];
}

class ImageGenerationInitial extends ImageGenerationState {}

class ImagesLoadingState extends ImageGenerationState {}

class ImagesLoadedState extends ImageGenerationState {
  final List<String> images;

  const ImagesLoadedState(this.images);

  @override
  List<Object?> get props => [images];
}

class ImageProcessingState extends ImageGenerationState {}

class ImageGeneratedState extends ImageGenerationState {
  final String generatedImagePath;

  const ImageGeneratedState(this.generatedImagePath);

  @override
  List<Object?> get props => [generatedImagePath];
}

class ImageGenerationErrorState extends ImageGenerationState {
  final String message;

  const ImageGenerationErrorState(this.message);

  @override
  List<Object?> get props => [message];
}









































// import 'package:equatable/equatable.dart';

// abstract class ImageGenerationState extends Equatable {
//   const ImageGenerationState();

//   @override
//   List<Object?> get props => [];
// }

// class ImageGenerationInitial extends ImageGenerationState {}

// class ImageSelectedState extends ImageGenerationState {
//   final String imagePath;

//   const ImageSelectedState(this.imagePath);

//   @override
//   List<Object?> get props => [imagePath];
// }

// class ImageProcessingState extends ImageGenerationState {}

// class ImageGeneratedState extends ImageGenerationState {
//   final String generatedImagePath;

//   const ImageGeneratedState(this.generatedImagePath);

//   @override
//   List<Object?> get props => [generatedImagePath];
// }

// class ImageGenerationErrorState extends ImageGenerationState {
//   final String message;

//   const ImageGenerationErrorState(this.message);

//   @override
//   List<Object?> get props => [message];
// }