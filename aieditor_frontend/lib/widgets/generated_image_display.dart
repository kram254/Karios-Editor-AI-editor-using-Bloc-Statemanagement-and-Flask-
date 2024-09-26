import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeneratedImageDisplay extends StatelessWidget {
  final String imagePath;

  const GeneratedImageDisplay({Key? key, required this.imagePath}) : super(key: key);

  Future<void> _downloadImage(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(imagePath));
      final bytes = response.bodyBytes;
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = imagePath.split('/').last;
      final file = File('${appDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image downloaded to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Image.network(
            imagePath,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Text('Error loading image.');
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _downloadImage(context),
            child: const Text('Download Image'),
          ),
        ],
      ),
    );
  }
}