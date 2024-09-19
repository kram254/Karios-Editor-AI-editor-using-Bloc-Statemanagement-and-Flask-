import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/image_display.dart';
import 'package:provider/provider.dart';

class ObjectRemovalScreen extends StatefulWidget {
  const ObjectRemovalScreen({super.key});

  @override
  _ObjectRemovalScreenState createState() => _ObjectRemovalScreenState();
}

class _ObjectRemovalScreenState extends State<ObjectRemovalScreen> {
  File? _selectedImage;
  String? _processedImagePath;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _processedImagePath = null;
      });
    }
  }

  Future<void> _removeObject() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    String? path = await apiService.removeObject(image: _selectedImage!);

    setState(() {
      _processedImagePath = path;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Remove Object'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
              _isLoading
                  ? const CircularProgressIndicator()
                  : ImageDisplay(imagePath: _processedImagePath),
            ],
          ),
        ));
  }
}