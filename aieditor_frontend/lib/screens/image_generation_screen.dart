import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_button.dart';
import '../bloc/image_generation/image_generation_bloc.dart';
import '../bloc/image_generation/image_generation_event.dart';
import '../bloc/image_generation/image_generation_state.dart';
import '../widgets/expanded_image_view.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageGenerationScreen extends StatefulWidget {
  const ImageGenerationScreen({Key? key}) : super(key: key);

  @override
  _ImageGenerationScreenState createState() => _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing images when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<ImageGenerationBloc>(context).add(LoadImagesEvent());
    });
  }

  void _generateImage() {
    if (_promptController.text.isNotEmpty) {
      BlocProvider.of<ImageGenerationBloc>(context)
          .add(GenerateImageEvent(_promptController.text));
      _promptController.clear();
    }
  }

  void _showExpandedImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpandedImageView(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = imageUrl.split('/').last;
        final file = File('${appDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded to ${file.path}')),
        );
      } else {
        throw Exception('Failed to download image.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image: $e')),
      );
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
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Enter prompt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: _generateImage,
              text: 'Generate',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
                builder: (context, state) {
                  if (state is ImagesLoadingState || state is ImageProcessingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ImagesLoadedState) {
                    List<String> images = state.images;

                    if (images.isEmpty) {
                      return const Center(child: Text('No images generated yet.'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        BlocProvider.of<ImageGenerationBloc>(context).add(LoadImagesEvent());
                      },
                      child: GridView.builder(
                        itemCount: images.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Adjust as needed
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final imageUrl = images[index];
                          return GestureDetector(
                            onTap: () => _showExpandedImage(imageUrl),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.broken_image));
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () => _downloadImage(context, imageUrl),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is ImageGenerationErrorState) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: Text('Enter a prompt to generate an image.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

























// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../widgets/custom_button.dart';
// import '../bloc/image_generation/image_generation_bloc.dart';
// import '../bloc/image_generation/image_generation_event.dart';
// import '../bloc/image_generation/image_generation_state.dart';
// import '../widgets/expanded_image_view.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// class ImageGenerationScreen extends StatefulWidget {
//   const ImageGenerationScreen({Key? key}) : super(key: key);

//   @override
//   _ImageGenerationScreenState createState() => _ImageGenerationScreenState();
// }

// class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
//   final TextEditingController _promptController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Load existing images when the screen initializes
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       BlocProvider.of<ImageGenerationBloc>(context).add(LoadImagesEvent());
//     });
//   }

//   void _generateImage() {
//     if (_promptController.text.isNotEmpty) {
//       BlocProvider.of<ImageGenerationBloc>(context)
//           .add(GenerateImageEvent(_promptController.text));
//       _promptController.clear();
//     }
//   }

//   void _showExpandedImage(String imageUrl) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ExpandedImageView(imageUrl: imageUrl),
//       ),
//     );
//   }

//   Future<void> _downloadImage(BuildContext context, String imageUrl) async {
//     try {
//       final response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         final bytes = response.bodyBytes;
//         final appDir = await getApplicationDocumentsDirectory();
//         final fileName = imageUrl.split('/').last;
//         final file = File('${appDir.path}/$fileName');
//         await file.writeAsBytes(bytes);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image downloaded to ${file.path}')),
//         );
//       } else {
//         throw Exception('Failed to download image.');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to download image: $e')),
//       );
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
//         child: Column(
//           children: [
//             TextField(
//               controller: _promptController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter prompt',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             CustomButton(
//               onPressed: _generateImage,
//               text: 'Generate',
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
//                 builder: (context, state) {
//                   if (state is ImagesLoadingState || state is ImageProcessingState) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (state is ImagesLoadedState) {
//                     List<String> images = state.images;

//                     if (images.isEmpty) {
//                       return const Center(child: Text('No images generated yet.'));
//                     }

//                     return RefreshIndicator(
//                       onRefresh: () async {
//                         BlocProvider.of<ImageGenerationBloc>(context).add(LoadImagesEvent());
//                       },
//                       child: GridView.builder(
//                         itemCount: images.length,
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                         ),
//                         itemBuilder: (context, index) {
//                           final imageUrl = images[index];
//                           return GestureDetector(
//                             onTap: () => _showExpandedImage(imageUrl),
//                             child: Stack(
//                               children: [
//                                 Positioned.fill(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(8.0),
//                                     child: Image.network(
//                                       imageUrl,
//                                       fit: BoxFit.cover,
//                                       loadingBuilder: (context, child, progress) {
//                                         if (progress == null) return child;
//                                         return const Center(child: CircularProgressIndicator());
//                                       },
//                                       errorBuilder: (context, error, stackTrace) {
//                                         return const Center(child: Icon(Icons.broken_image));
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   right: 8,
//                                   top: 8,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.black54,
//                                       borderRadius: BorderRadius.circular(4.0),
//                                     ),
//                                     child: IconButton(
//                                       icon: const Icon(
//                                         Icons.download,
//                                         color: Colors.white,
//                                         size: 20,
//                                       ),
//                                       onPressed: () => _downloadImage(context, imageUrl),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   } else if (state is ImageGenerationErrorState) {
//                     return Center(child: Text(state.message));
//                   } else {
//                     return const Center(child: Text('Enter a prompt to generate an image.'));
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }















// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../widgets/custom_button.dart';
// import '../bloc/image_generation/image_generation_bloc.dart';
// import '../bloc/image_generation/image_generation_event.dart';
// import '../bloc/image_generation/image_generation_state.dart';
// import '../widgets/expanded_image_view.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// class ImageGenerationScreen extends StatefulWidget {
//   const ImageGenerationScreen({super.key});

//   @override
//   _ImageGenerationScreenState createState() => _ImageGenerationScreenState();
// }

// class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
//   final TextEditingController _promptController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Load existing images when the screen initializes
//     BlocProvider.of<ImageGenerationBloc>(context).add(LoadImagesEvent());
//   }

//   void _generateImage() {
//     if (_promptController.text.isNotEmpty) {
//       BlocProvider.of<ImageGenerationBloc>(context)
//           .add(GenerateImageEvent(_promptController.text));
//       _promptController.clear();
//     }
//   }

//   void _showExpandedImage(String imageUrl) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ExpandedImageView(imageUrl: imageUrl),
//       ),
//     );
//   }

//   Future<void> _downloadImage(BuildContext context, String imageUrl) async {
//     try {
//       final response = await http.get(Uri.parse(imageUrl));
//       final bytes = response.bodyBytes;
//       final appDir = await getApplicationDocumentsDirectory();
//       final fileName = imageUrl.split('/').last;
//       final file = File('${appDir.path}/$fileName');
//       await file.writeAsBytes(bytes);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Image downloaded to ${file.path}')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to download image: $e')),
//       );
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
//               Expanded(
//                 child: BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
//                   builder: (context, state) {
//                     if (state is ImagesLoadingState) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state is ImagesLoadedState) {
//                       if (state.images.isEmpty) {
//                         return const Center(child: Text('No images generated yet.'));
//                       }
//                       return GridView.builder(
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 10.0,
//                           mainAxisSpacing: 10.0,
//                           childAspectRatio: 1.0,
//                         ),
//                         itemCount: state.images.length,
//                         itemBuilder: (context, index) {
//                           final imageUrl = state.images[index];
//                           return GestureDetector(
//                             onTap: () => _showExpandedImage(imageUrl),
//                             child: Stack(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   child: Image.network(
//                                     imageUrl,
//                                     fit: BoxFit.cover,
//                                     width: double.infinity,
//                                     height: double.infinity,
//                                     loadingBuilder: (context, child, loadingProgress) {
//                                       if (loadingProgress == null) return child;
//                                       return const Center(
//                                         child: CircularProgressIndicator(),
//                                       );
//                                     },
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return const Center(child: Icon(Icons.broken_image));
//                                     },
//                                   ),
//                                 ),
//                                 Positioned(
//                                   right: 8,
//                                   top: 8,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.black54,
//                                       borderRadius: BorderRadius.circular(4.0),
//                                     ),
//                                     child: IconButton(
//                                       icon: const Icon(
//                                         Icons.download,
//                                         color: Colors.white,
//                                         size: 20,
//                                       ),
//                                       onPressed: () => _downloadImage(context, imageUrl),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     } else if (state is ImageGenerationErrorState) {
//                       return Center(child: Text(state.message));
//                     } else {
//                       return const Center(child: Text('Enter a prompt to generate an image.'));
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
//   //  import 'package:flutter/material.dart';
//   //  import 'package:flutter_bloc/flutter_bloc.dart';
//   //  import '../widgets/image_display.dart';
//   //  import '../widgets/custom_button.dart';
//   //  import '../bloc/image_generation/image_generation_bloc.dart';
//   //  import '../bloc/image_generation/image_generation_event.dart';
//   //  import '../bloc/image_generation/image_generation_state.dart';

//   //  class ImageGenerationScreen extends StatefulWidget {
//   //    const ImageGenerationScreen({super.key});

//   //    @override
//   //    _ImageGenerationScreenState createState() => _ImageGenerationScreenState();
//   //  }

//   //  class _ImageGenerationScreenState extends State<ImageGenerationScreen> {
//   //    final TextEditingController _promptController = TextEditingController();

//   //    void _generateImage() {
//   //      if (_promptController.text.isNotEmpty) {
//   //        BlocProvider.of<ImageGenerationBloc>(context)
//   //            .add(GenerateImageEvent(_promptController.text));
//   //      }
//   //    }

//   //    @override
//   //    Widget build(BuildContext context) {
//   //      return Scaffold(
//   //        appBar: AppBar(
//   //          title: const Text('Generate Image'),
//   //        ),
//   //        body: Padding(
//   //          padding: const EdgeInsets.all(16.0),
//   //          child: BlocListener<ImageGenerationBloc, ImageGenerationState>(
//   //            listener: (context, state) {
//   //              if (state is ImageGenerationErrorState) {
//   //                ScaffoldMessenger.of(context).showSnackBar(
//   //                  SnackBar(content: Text(state.message)),
//   //                );
//   //              } else if (state is ImageGeneratedState) {
//   //                ScaffoldMessenger.of(context).showSnackBar(
//   //                  const SnackBar(content: Text('Image Generated Successfully')),
//   //                );
//   //              }
//   //            },
//   //            child: Column(
//   //              children: [
//   //                TextField(
//   //                  controller: _promptController,
//   //                  decoration: const InputDecoration(
//   //                    labelText: 'Image Description',
//   //                    border: OutlineInputBorder(),
//   //                  ),
//   //                ),
//   //                const SizedBox(height: 20),
//   //                CustomButton(
//   //                  text: 'Generate',
//   //                  onPressed: _generateImage,
//   //                ),
//   //                const SizedBox(height: 20),
                 
//   //                BlocBuilder<ImageGenerationBloc, ImageGenerationState>(
//   //                  builder: (context, state) {
//   //                    if (state is ImageProcessingState) {
//   //                      return const CircularProgressIndicator();
//   //                    } else if (state is ImageGeneratedState) {
//   //                      return ImageDisplay(imagePath: state.generatedImagePath);
//   //                    } else {
//   //                      return const Text('Enter a prompt to generate an image.');
//   //                    }
//   //                  },
//   //                ),
//   //              ],
//   //            ),
//   //          ),
//   //        ),
//   //      );
//   //    }
//   //  }




