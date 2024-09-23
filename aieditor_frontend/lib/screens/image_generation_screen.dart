import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/image_display.dart';
import '../widgets/custom_button.dart';
import '../bloc/image_generation/image_generation_bloc.dart';
import '../bloc/image_generation/image_generation_event.dart';
import '../bloc/image_generation/image_generation_state.dart';

class ImageGenerationScreen extends StatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  _ImageGenerationScreenState createState() => _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();

  void _generateImage() {
    if (_promptController.text.isNotEmpty) {
      BlocProvider.of<ImageGenerationBloc>(context)
          .add(GenerateImageEvent(_promptController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<ImageGenerationBloc, ImageGenerationState>(
          listener: (context, state) {
            if (state is ImageGenerationErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ImageGeneratedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image Generated Successfully')),
              );
            }
          },
          child: Column(
            children: [
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
              BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
                builder: (context, state) {
                  if (state is ImageProcessingState) {
                    return const CircularProgressIndicator();
                  } else if (state is ImageGeneratedState) {
                    return ImageDisplay(imagePath: state.generatedImagePath);
                  } else {
                    return const Text('Enter a prompt to generate an image.');
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






























// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import '../widgets/image_display.dart';
// import '../widgets/custom_button.dart';
// import '../bloc/image_generation/image_generation_bloc.dart';
// import '../bloc/image_generation/image_generation_event.dart';
// import '../bloc/image_generation/image_generation_state.dart';

// class ImageGenerationScreen extends StatefulWidget {
//   const ImageGenerationScreen({super.key});

//   @override
//   _ImageGenerationScreenState createState() => _ImageGenerationScreenState();
// }

// class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
//   final TextEditingController _promptController = TextEditingController();

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       BlocProvider.of<ImageGenerationBloc>(context)
//           .add(SelectImageEvent(File(picked.path)));
//     }
//   }

//   void _generateImage() {
//     if (_promptController.text.isNotEmpty) {
//       BlocProvider.of<ImageGenerationBloc>(context)
//           .add(GenerateImageEvent(_promptController.text));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Generate Image'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: BlocListener<ImageGenerationBloc, ImageGenerationState>(
//           listener: (context, state) {
//             if (state is ImageGenerationErrorState) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.message)),
//               );
//             } else if (state is ImageGeneratedState) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Image Generated Successfully')),
//               );
//             }
//           },
//           child: Column(
//             children: [
//               CustomButton(
//                 text: 'Select Image',
//                 onPressed: _pickImage,
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: _promptController,
//                 decoration: const InputDecoration(
//                   labelText: 'Image Description',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               CustomButton(
//                 text: 'Generate',
//                 onPressed: _generateImage,
//               ),
//               const SizedBox(height: 20),
//               BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
//                 builder: (context, state) {
//                   if (state is ImageProcessingState) {
//                     return const CircularProgressIndicator();
//                   } else if (state is ImageGeneratedState) {
//                     return ImageDisplay(imagePath: state.generatedImagePath);
//                   } else if (state is ImageSelectedState) {
//                     return ImageDisplay(imagePath: state.imagePath);
//                   } else {
//                     return const Text('No image selected.');
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }