// aieditor_frontend/lib/screens/object_cutter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../bloc/object_cutter/object_cutter_bloc.dart';
import '../bloc/object_cutter/object_cutter_event.dart';
import '../bloc/object_cutter/object_cutter_state.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ObjectCutterScreen extends StatefulWidget {
  const ObjectCutterScreen({Key? key}) : super(key: key);

  @override
  _ObjectCutterScreenState createState() => _ObjectCutterScreenState();
}

class _ObjectCutterScreenState extends State<ObjectCutterScreen> {
  final TextEditingController _promptController = TextEditingController();
  File? _selectedImage;
  String? _uploadedImageUrl;
  String? _editedImageUrl;
  List<ImagePair> _imagePairs = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _uploadedImageUrl = null;
        _editedImageUrl = null;
      });
      BlocProvider.of<ObjectCutterBloc>(context)
          .add(UploadImageEvent(_selectedImage!));
    }
  }

  void _applyPrompt() {
    final prompt = _promptController.text.trim();
    if (prompt.isNotEmpty) {
      context.read<ObjectCutterBloc>().add(ApplyPromptEvent(prompt));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt.')),
      );
    }
  }

  Future<void> _downloadImage(String imageUrl, String filename) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        var bytes = response.bodyBytes;
        var dir = await getApplicationDocumentsDirectory();
        File file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded to ${file.path}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download image: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Cutter'),
      ),
      body: BlocConsumer<ObjectCutterBloc, ObjectCutterState>(
        listener: (context, state) {
          if (state is ObjectCutterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ObjectCutterSuccess) {
            setState(() {
              _editedImageUrl = state.editedImage;
              _imagePairs.add(ImagePair(
                original: state.originalImage,
                edited: state.editedImage,
                prompt: _promptController.text.trim(),
              ));
            });
          } else if (state is ObjectCutterUploaded) {
            setState(() {
              _uploadedImageUrl = state.originalImage;
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Image Picker Section
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select Image'),
                ),
                const SizedBox(height: 20),
                // Display Selected Image
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                      )
                    : const Text('No image selected'),
                const SizedBox(height: 20),
                // Prompt Input Section
                TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    labelText: 'Enter prompt',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _promptController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Apply Prompt Button
                ElevatedButton(
                  onPressed: (state is ObjectCutterLoading) ? null : _applyPrompt,
                  child: const Text('Apply Prompt'),
                ),
                const SizedBox(height: 20),
                // Loading Indicator
                if (state is ObjectCutterLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                ],
                // Display Original and Edited Images
                if (_uploadedImageUrl != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Uploaded Image:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.network(
                        _uploadedImageUrl!,
                        height: 200,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              final filename = _uploadedImageUrl!.split('/').last;
                              _downloadImage(_uploadedImageUrl!, filename);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                // Display Edited Image
                if (_editedImageUrl != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edited Image:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Image.network(
                        _editedImageUrl!,
                        height: 200,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              final filename = _editedImageUrl!.split('/').last;
                              _downloadImage(_editedImageUrl!, filename);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // Display Previous Edits
                if (_imagePairs.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Previous Edits:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _imagePairs.length,
                    itemBuilder: (context, index) {
                      final pair = _imagePairs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prompt: ${pair.prompt}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Image.network(pair.original, height: 100),
                                        const SizedBox(height: 5),
                                        const Text('Original'),
                                        IconButton(
                                          icon: const Icon(Icons.download),
                                          onPressed: () {
                                            final filename = pair.original.split('/').last;
                                            _downloadImage(pair.original, filename);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Image.network(pair.edited, height: 100),
                                        const SizedBox(height: 5),
                                        const Text('Edited'),
                                        IconButton(
                                          icon: const Icon(Icons.download),
                                          onPressed: () {
                                            final filename = pair.edited.split('/').last;
                                            _downloadImage(pair.edited, filename);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class ImagePair {
  final String original;
  final String edited;
  final String prompt;

  ImagePair({
    required this.original,
    required this.edited,
    required this.prompt,
  });
}


















































// // aieditor_frontend/lib/screens/object_cutter_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import '../bloc/object_cutter/object_cutter_bloc.dart';
// import '../bloc/object_cutter/object_cutter_event.dart';
// import '../bloc/object_cutter/object_cutter_state.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class ObjectCutterScreen extends StatefulWidget {
//   const ObjectCutterScreen({Key? key}) : super(key: key);

//   @override
//   _ObjectCutterScreenState createState() => _ObjectCutterScreenState();
// }

// class _ObjectCutterScreenState extends State<ObjectCutterScreen> {
//   final TextEditingController _promptController = TextEditingController();
//   File? _selectedImage;
//   String? _uploadedImageUrl;
//   String? _editedImageUrl;
//   List<ImagePair> _imagePairs = [];

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile =
//         await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//         _uploadedImageUrl = null;
//         _editedImageUrl = null;
//       });
//       BlocProvider.of<ObjectCutterBloc>(context)
//           .add(UploadImageEvent(_selectedImage!));
//     }
//   }

//     void _applyPrompt() {
//     final prompt = _promptController.text.trim();
//     if (prompt.isNotEmpty) {
//       context.read<ObjectCutterBloc>().add(ApplyPromptEvent(prompt));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a prompt.')),
//       );
//     }
//   }

//   // void _applyPrompt() {
//   //   if (_promptController.text.isNotEmpty && _selectedImage != null) {
//   //     BlocProvider.of<ObjectCutterBloc>(context)
//   //         .add(ApplyPromptEvent(_promptController.text));
//   //     _promptController.clear();
//   //   }
//   // }

  
//   Future<void> _downloadImage(String imageUrl, String filename) async {
//     try {
//       var response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode == 200) {
//         var bytes = response.bodyBytes;
//         var dir = await getApplicationDocumentsDirectory();
//         File file = File('${dir.path}/$filename');
//         await file.writeAsBytes(bytes);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image downloaded to ${file.path}')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to download image: ${response.statusCode}')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error downloading image: $e')),
//       );
//     }
//   }




//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Object Cutter'),
//         ),
        

//          body: BlocConsumer<ObjectCutterBloc, ObjectCutterState>(
//         listener: (context, state) {
//           if (state is ObjectCutterSuccess) {
//             setState(() {
//               _uploadedImageUrl = state.originalImage;
//               _editedImageUrl = state.editedImage;
//               _imagePairs.add(ImagePair(
//                 original: state.originalImage,
//                 edited: state.editedImage,
//                 prompt: _promptController.text,
//               ));
//             });
//           } else if (state is ObjectCutterError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _pickImage,
//                     child: const Text('Select Image'),
//                   ),
//                   const SizedBox(height: 16),
//                   if (_selectedImage != null)
//                     Image.file(_selectedImage!, height: 200),
//                   if (_uploadedImageUrl != null)
//                     Image.network(_uploadedImageUrl!, height: 200),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _promptController,
//                     decoration: const InputDecoration(
//                       labelText: 'Enter prompt',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: state is! ObjectCutterLoading ? _applyPrompt : null,
//                     child: state is ObjectCutterLoading
//                         ? const CircularProgressIndicator()
//                         : const Text('Apply Prompt'),
//                   ),
//                   if (_editedImageUrl != null) ...[
//                     const SizedBox(height: 16),
//                     Image.network(_editedImageUrl!, height: 200),
//                   ],
//                   const SizedBox(height: 32),
//                   const Text('Previous Edits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: _imagePairs.length,
//                     itemBuilder: (context, index) {
//                       final pair = _imagePairs[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text('Prompt: ${pair.prompt}'),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       children: [
//                                         Image.network(pair.original, height: 100),
//                                         const Text('Original'),
//                                         IconButton(
//                                           icon: const Icon(Icons.download),
//                                           onPressed: () {
//                                             final filename = pair.original.split('/').last;
//                                             _downloadImage(pair.original, filename);
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Column(
//                                       children: [
//                                         Image.network(pair.edited, height: 100),
//                                         const Text('Edited'),
//                                         IconButton(
//                                           icon: const Icon(Icons.download),
//                                           onPressed: () {
//                                             final filename = pair.edited.split('/').last;
//                                             _downloadImage(pair.edited, filename);
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),

       
//         );
//   }
// }

// class ImagePair {
//   final String original;
//   final String edited;
//   final String prompt;

//   ImagePair({
//     required this.original,
//     required this.edited,
//     required this.prompt,
//   });
// }






































// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import '../bloc/object_cutter/object_cutter_bloc.dart';
// import '../bloc/object_cutter/object_cutter_event.dart';
// import '../bloc/object_cutter/object_cutter_state.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class ObjectCutterScreen extends StatefulWidget {
//   const ObjectCutterScreen({Key? key}) : super(key: key);

//   @override
//   _ObjectCutterScreenState createState() => _ObjectCutterScreenState();
// }

// class _ObjectCutterScreenState extends State<ObjectCutterScreen> {
//   final TextEditingController _promptController = TextEditingController();
//   File? _selectedImage;
//   String? _originalImageUrl;
//   String? _editedImageUrl;
//   List<ImagePair> _imagePairs = [];

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile =
//         await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//         _originalImageUrl = null;
//         _editedImageUrl = null;
//       });
//       BlocProvider.of<ObjectCutterBloc>(context)
//           .add(UploadImageEvent(_selectedImage!));
//     }
//   }

//   void _applyPrompt() {
//     if (_promptController.text.isNotEmpty && _selectedImage != null) {
//       BlocProvider.of<ObjectCutterBloc>(context)
//           .add(ApplyPromptEvent(_promptController.text));
//       _promptController.clear();
//     }
//   }

//   Future<void> _downloadImage(String url, String filename) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final bytes = response.bodyBytes;
//         final directory = await getApplicationDocumentsDirectory();
//         final file = File('${directory.path}/$filename');
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
//         appBar: AppBar(
//           title: Text('Object Cutter'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: BlocListener<ObjectCutterBloc, ObjectCutterState>(
//               listener: (context, state) {
//                 if (state is ObjectCutterSuccess) {
//                   setState(() {
//                     _originalImageUrl = state.originalImage;
//                     _editedImageUrl = state.editedImage;
//                     _imagePairs.insert(
//                         0,
//                         ImagePair(
//                             original: state.originalImage,
//                             edited: state.editedImage,
//                             prompt: _promptController.text));
//                   });
//                 } else if (state is ObjectCutterError) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(state.message)),
//                   );
//                 }
//               },
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _pickImage,
//                     child: Text('Upload Image'),
//                   ),
//                   const SizedBox(height: 10),
//                   if (_selectedImage != null)
//                     Container(
//                       height: 300,
//                       width: 200,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(8.0),
//                         image: DecorationImage(
//                           image: FileImage(_selectedImage!),
//                           fit: BoxFit.fitWidth
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   Divider(
//                     thickness: 2,
//                     color: Colors.grey[300],
//                   ),
//                   const SizedBox(height: 20),
//                   if (_editedImageUrl != null)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text(
//                           'Processed Image',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 10),
//                         Stack(
//                           children: [
//                             Container(
//                               height: 200,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey),
//                                 borderRadius: BorderRadius.circular(8.0),
//                                 image: DecorationImage(
//                                   image: NetworkImage(_editedImageUrl!),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               right: 8,
//                               top: 8,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   borderRadius: BorderRadius.circular(4.0),
//                                 ),
//                                 child: IconButton(
//                                   icon: Icon(
//                                     Icons.download,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                   onPressed: () {
//                                     final filename =
//                                         _editedImageUrl!.split('/').last;
//                                     _downloadImage(_editedImageUrl!, filename);
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   const SizedBox(height: 20),
//                   TextField(
//                     controller: _promptController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter prompt',
//                       border: OutlineInputBorder(),
//                       suffixIcon: IconButton(
//                         icon: Icon(Icons.clear),
//                         onPressed: () {
//                           _promptController.clear();
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _applyPrompt,
//                     child: Text('Apply Prompt'),
//                   ),
//                   const SizedBox(height: 30),
//                   Text(
//                     'Recent Edits',
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   _imagePairs.isEmpty
//                       ? Center(child: Text('No edits yet.'))
//                       : GridView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   crossAxisSpacing: 10,
//                                   mainAxisSpacing: 10),
//                           itemCount: _imagePairs.length,
//                           itemBuilder: (context, index) {
//                             final pair = _imagePairs[index];
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Prompt: ${pair.prompt}',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Expanded(
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(8.0),
//                                     child: Stack(
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                               child: Column(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Image.network(
//                                                       pair.original,
//                                                       fit: BoxFit.cover,
//                                                       width: double.infinity,
//                                                       loadingBuilder:
//                                                           (context, child,
//                                                               loadingProgress) {
//                                                         if (loadingProgress ==
//                                                             null)
//                                                           return child;
//                                                         return Center(
//                                                             child:
//                                                                 CircularProgressIndicator());
//                                                       },
//                                                       errorBuilder: (context,
//                                                           error,
//                                                           stackTrace) {
//                                                         return Center(
//                                                             child: Icon(
//                                                                 Icons
//                                                                     .broken_image));
//                                                       },
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 5),
//                                                   Text('Original',
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold)),
//                                                 ],
//                                               ),
//                                             ),
//                                             SizedBox(width: 5),
//                                             Expanded(
//                                               child: Column(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Image.network(
//                                                       pair.edited,
//                                                       fit: BoxFit.cover,
//                                                       width: double.infinity,
//                                                       loadingBuilder:
//                                                           (context, child,
//                                                               loadingProgress) {
//                                                         if (loadingProgress ==
//                                                             null)
//                                                           return child;
//                                                         return Center(
//                                                             child:
//                                                                 CircularProgressIndicator());
//                                                       },
//                                                       errorBuilder: (context,
//                                                           error,
//                                                           stackTrace) {
//                                                         return Center(
//                                                             child: Icon(
//                                                                 Icons
//                                                                     .broken_image));
//                                                       },
//                                                     ),
//                                                   ),
//                                                   SizedBox(height: 5),
//                                                   Text('Edited',
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold)),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Positioned(
//                                           right: 8,
//                                           top: 8,
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               color: Colors.black54,
//                                               borderRadius:
//                                                   BorderRadius.circular(4.0),
//                                             ),
//                                             child: IconButton(
//                                               icon: Icon(
//                                                 Icons.download,
//                                                 color: Colors.white,
//                                                 size: 16,
//                                               ),
//                                               onPressed: () {
//                                                 final filename =
//                                                     pair.edited.split('/').last;
//                                                 _downloadImage(pair.edited, filename);
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }

// class ImagePair {
//   final String original;
//   final String edited;
//   final String prompt;

//   ImagePair({
//     required this.original,
//     required this.edited,
//     required this.prompt,
//   });
// }















