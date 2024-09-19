import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/image_display.dart';
import 'package:provider/provider.dart';

class ImageGenerationScreen extends StatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  _ImageGenerationScreenState createState() => _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
  File? _selectedImage;
  String? _processedImagePath;
  bool _isLoading = false;
  final TextEditingController _promptController = TextEditingController();

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

  Future<void> _generateImage() async {
    if (_selectedImage == null || _promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final apiService = Provider.of<ApiService>(context, listen: false);
    String? path = await apiService.processImage(
      image: _selectedImage!,
      prompt: _promptController.text,
    );

    setState(() {
      _processedImagePath = path;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Generate Image'),
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
              TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  labelText: 'Image Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Generate',
                onPressed: _generateImage,
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