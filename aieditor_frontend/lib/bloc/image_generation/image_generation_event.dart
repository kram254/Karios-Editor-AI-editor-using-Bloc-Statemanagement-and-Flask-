import 'package:equatable/equatable.dart';

abstract class ImageGenerationEvent extends Equatable {
  const ImageGenerationEvent();

  @override
  List<Object?> get props => [];
}

class GenerateImageEvent extends ImageGenerationEvent {
  final String prompt;

  const GenerateImageEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

class LoadImagesEvent extends ImageGenerationEvent {}
































// import 'dart:io';
// import 'package:equatable/equatable.dart';

// abstract class ImageGenerationEvent extends Equatable {
//   const ImageGenerationEvent();

//   @override
//   List<Object?> get props => [];
// }

// class SelectImageEvent extends ImageGenerationEvent {
//   final File image;

//   const SelectImageEvent(this.image);

//   @override
//   List<Object?> get props => [image];
// }

// class GenerateImageEvent extends ImageGenerationEvent {
//   final String prompt;

//   const GenerateImageEvent(this.prompt);

//   @override
//   List<Object?> get props => [prompt];
// }