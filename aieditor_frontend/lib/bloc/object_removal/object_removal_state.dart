import 'package:equatable/equatable.dart';

abstract class ObjectRemovalState extends Equatable {
  const ObjectRemovalState();

  @override
  List<Object?> get props => [];
}

class ObjectRemovalInitial extends ObjectRemovalState {}

class ObjectSelectedForRemovalState extends ObjectRemovalState {
  final String imagePath;

  const ObjectSelectedForRemovalState(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ObjectRemovingState extends ObjectRemovalState {}

class ObjectRemovedState extends ObjectRemovalState {
  final String processedImagePath;

  const ObjectRemovedState(this.processedImagePath);

  @override
  List<Object?> get props => [processedImagePath];
}

class ObjectRemovalErrorState extends ObjectRemovalState {
  final String message;

  const ObjectRemovalErrorState(this.message);

  @override
  List<Object?> get props => [message];
}