import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../bloc/object_cutter/object_cutter_bloc.dart';
import '../bloc/object_cutter/object_cutter_event.dart';
import '../bloc/object_cutter/object_cutter_state.dart';

class ObjectCutterScreen extends StatefulWidget {
  const ObjectCutterScreen({Key? key}) : super(key: key);

  @override
  _ObjectCutterScreenState createState() => _ObjectCutterScreenState();
}

class _ObjectCutterScreenState extends State<ObjectCutterScreen> {
  final TextEditingController _promptController = TextEditingController();
  File? _selectedImage;
  String? _originalImageUrl;
  String? _editedImageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      BlocProvider.of<ObjectCutterBloc>(context)
          .add(UploadImageEvent(_selectedImage!));
    }
  }

  void _applyPrompt() {
    if (_promptController.text.isNotEmpty) {
      BlocProvider.of<ObjectCutterBloc>(context)
          .add(ApplyPromptEvent(_promptController.text));
      _promptController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Object Cutter'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<ObjectCutterBloc, ObjectCutterState>(
            listener: (context, state) {
              if (state is ObjectCutterSuccess) {
                setState(() {
                  _originalImageUrl = state.originalImage;
                  _editedImageUrl = state.editedImage;
                });
              } else if (state is ObjectCutterError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Image'),
                ),
                const SizedBox(height: 20),
                if (_originalImageUrl != null && _editedImageUrl != null)
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        String? imageUrl;
                        String label = '';
                        if (index == 0) {
                          imageUrl = _originalImageUrl;
                          label = 'Original';
                        } else if (index == 1) {
                          imageUrl = _editedImageUrl;
                          label = 'Edited';
                        }
                        return Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Center(
                                      child: Icon(Icons.broken_image));
                                },
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    labelText: 'Enter prompt',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _promptController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _applyPrompt,
                  child: Text('Apply Prompt'),
                ),
              ],
            ),
          ),
        ));
  }
}