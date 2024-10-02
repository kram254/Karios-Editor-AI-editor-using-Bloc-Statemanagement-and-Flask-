// aieditor_frontend/lib/bloc/object_cutter/object_cutter_state.dart
import 'package:equatable/equatable.dart';

abstract class ObjectCutterState extends Equatable {
  const ObjectCutterState();

  @override
  List<Object> get props => [];
}

class ObjectCutterInitial extends ObjectCutterState {}

class ObjectCutterLoading extends ObjectCutterState {}

class ObjectCutterUploaded extends ObjectCutterState {
  final String originalImage;

  const ObjectCutterUploaded(this.originalImage);

  @override
  List<Object> get props => [originalImage];
}

class ObjectCutterSuccess extends ObjectCutterState {
  final String originalImage;
  final String editedImage;

  const ObjectCutterSuccess(this.originalImage, this.editedImage);

  @override
  List<Object> get props => [originalImage, editedImage];
}

class ObjectCutterError extends ObjectCutterState {
  final String message;

  const ObjectCutterError(this.message);

  @override
  List<Object> get props => [message];
}
















// import 'package:equatable/equatable.dart';

// abstract class ObjectCutterState extends Equatable {
//   const ObjectCutterState();

//   @override
//   List<Object> get props => [];
// }

// class ObjectCutterInitial extends ObjectCutterState {}

// class ObjectCutterLoading extends ObjectCutterState {}

// class ObjectCutterSuccess extends ObjectCutterState {
//   final String originalImage;
//   final String editedImage;

//   const ObjectCutterSuccess(this.originalImage, this.editedImage);

//   @override
//   List<Object> get props => [originalImage, editedImage];
// }

// class ObjectCutterError extends ObjectCutterState {
//   final String message;

//   const ObjectCutterError(this.message);

//   @override
//   List<Object> get props => [message];
// }