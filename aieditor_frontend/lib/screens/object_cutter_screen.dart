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
  String? _originalImageUrl;
  String? _editedImageUrl;
  List<ImagePair> _imagePairs = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _originalImageUrl = null;
        _editedImageUrl = null;
      });
      BlocProvider.of<ObjectCutterBloc>(context)
          .add(UploadImageEvent(_selectedImage!));
    }
  }

  void _applyPrompt() {
    if (_promptController.text.isNotEmpty && _selectedImage != null) {
      BlocProvider.of<ObjectCutterBloc>(context)
          .add(ApplyPromptEvent(_promptController.text));
      _promptController.clear();
    }
  }

  Future<void> _downloadImage(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
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
          title: Text('Object Cutter'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: BlocListener<ObjectCutterBloc, ObjectCutterState>(
              listener: (context, state) {
                if (state is ObjectCutterSuccess) {
                  setState(() {
                    _editedImageUrl = state.editedImage;
                    // Assuming _uploadedImageUrl is already set during UploadImageEvent
                    _imagePairs.insert(
                        0,
                        ImagePair(
                            original: _originalImageUrl!,
                            edited: state.editedImage,
                            prompt: _promptController.text));
                  });
                } else if (state is ObjectCutterUploaded) {
                  setState(() {
                    _originalImageUrl = state.originalImage;
                  });
                } else if (state is ObjectCutterError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Image'),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedImage != null)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Divider(
                    thickness: 2,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      labelText: 'Enter prompt to remove background',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _applyPrompt,
                    child: Text('Apply Prompt'),
                  ),
                  const SizedBox(height: 20),
                  if (_editedImageUrl != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Processed Image',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: NetworkImage(_editedImageUrl!),
                                  fit: BoxFit.cover,
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
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    final filename =
                                        _editedImageUrl!.split('/').last;
                                    _downloadImage(_editedImageUrl!, filename);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (_imagePairs.isNotEmpty)
                    Text(
                      'Recent Edits',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 10),
                  if (_imagePairs.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                      itemCount: _imagePairs.length,
                      itemBuilder: (context, index) {
                        final pair = _imagePairs[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prompt: ${pair.prompt}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Image.network(
                                                  pair.original,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  loadingBuilder: (context,
                                                      child,
                                                      loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Center(
                                                        child:
                                                            Icon(Icons.broken_image));
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text('Original',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Image.network(
                                                  pair.edited,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  loadingBuilder: (context,
                                                      child,
                                                      loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Center(
                                                        child:
                                                            Icon(Icons.broken_image));
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text('Edited',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.download,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          onPressed: () {
                                            final filename =
                                                pair.edited.split('/').last;
                                            _downloadImage(pair.edited, filename);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ));
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















