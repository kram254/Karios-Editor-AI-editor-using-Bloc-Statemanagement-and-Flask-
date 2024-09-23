import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/image_display.dart';
import '../widgets/custom_button.dart';
import '../bloc/object_removal/object_removal_bloc.dart';
import '../bloc/object_removal/object_removal_event.dart';
import '../bloc/object_removal/object_removal_state.dart';

class ObjectRemovalScreen extends StatefulWidget {
  const ObjectRemovalScreen({super.key});

  @override
  _ObjectRemovalScreenState createState() => _ObjectRemovalScreenState();
}

class _ObjectRemovalScreenState extends State<ObjectRemovalScreen> {
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      BlocProvider.of<ObjectRemovalBloc>(context)
          .add(SelectImageForRemovalEvent(File(picked.path)));
    }
  }

  void _removeObject() {
    BlocProvider.of<ObjectRemovalBloc>(context).add(RemoveObjectEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Object'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<ObjectRemovalBloc, ObjectRemovalState>(
          listener: (context, state) {
            if (state is ObjectRemovalErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ObjectRemovedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Object Removed Successfully')),
              );
            }
          },
          child: Column(
            children: [
              CustomButton(
                text: 'Select Image',
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Remove Object',
                onPressed: _removeObject,
              ),
              const SizedBox(height: 20),
              BlocBuilder<ObjectRemovalBloc, ObjectRemovalState>(
                builder: (context, state) {
                  if (state is ObjectRemovingState) {
                    return const CircularProgressIndicator();
                  } else if (state is ObjectRemovedState) {
                    return ImageDisplay(imagePath: state.processedImagePath);
                  } else if (state is ObjectSelectedForRemovalState) {
                    return ImageDisplay(imagePath: state.imagePath);
                  } else {
                    return const Text('No image selected.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}