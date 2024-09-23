import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ObjectRemovalEvent extends Equatable {
  const ObjectRemovalEvent();

  @override
  List<Object?> get props => [];
}

class SelectImageForRemovalEvent extends ObjectRemovalEvent {
  final File image;

  const SelectImageForRemovalEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class RemoveObjectEvent extends ObjectRemovalEvent {}