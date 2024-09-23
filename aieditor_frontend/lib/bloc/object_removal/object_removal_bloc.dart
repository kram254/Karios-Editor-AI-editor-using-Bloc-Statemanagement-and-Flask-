import 'dart:io';
import 'package:bloc/bloc.dart';
import 'object_removal_event.dart';
import 'object_removal_state.dart';
import '../../services/api_service.dart';

class ObjectRemovalBloc extends Bloc<ObjectRemovalEvent, ObjectRemovalState> {
  final ApiService apiService;
  String? _currentImagePath;

  ObjectRemovalBloc({required this.apiService}) : super(ObjectRemovalInitial()) {
    on<SelectImageForRemovalEvent>((event, emit) {
      _currentImagePath = event.image.path;
      emit(ObjectSelectedForRemovalState(event.image.path));
    });

    on<RemoveObjectEvent>((event, emit) async {
      if (_currentImagePath != null) {
        emit(ObjectRemovingState());
        try {
          final processedPath = await apiService.removeObject(image: File(_currentImagePath!));
          if (processedPath != null) {
            emit(ObjectRemovedState(processedPath));
          } else {
            emit(const ObjectRemovalErrorState('Failed to remove object.'));
          }
        } catch (e) {
          emit(ObjectRemovalErrorState(e.toString()));
        }
      }
    });
  }
}