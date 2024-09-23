import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final String? imagePath;

  const ImageDisplay({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return const Text('No image selected.');
    } else {
      return Expanded(
        child: Image.network(
          imagePath!,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Text('Error loading image.');
          },
        ),
      );
    }
  }
}