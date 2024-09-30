import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ObjectCutterEvent extends Equatable {
  const ObjectCutterEvent();

  @override
  List<Object> get props => [];
}

class UploadImageEvent extends ObjectCutterEvent {
  final File imageFile;

  const UploadImageEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class ApplyPromptEvent extends ObjectCutterEvent {
  final String prompt;

  const ApplyPromptEvent(this.prompt);

  @override
  List<Object> get props => [prompt];
}