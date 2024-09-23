import 'package:flutter/material.dart';
import 'image_generation_screen.dart';
import 'object_removal_screen.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomButton(
              text: 'Generate Image',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageGenerationScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Remove Object',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ObjectRemovalScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}