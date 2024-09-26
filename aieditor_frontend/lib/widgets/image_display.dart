   import 'package:flutter/material.dart';

   class ImageDisplay extends StatelessWidget {
     final String imagePath;

     const ImageDisplay({Key? key, required this.imagePath}) : super(key: key);

     @override
     Widget build(BuildContext context) {
       return Image.network(
         imagePath,
         loadingBuilder: (context, child, loadingProgress) {
           if (loadingProgress == null) return child;
           return Center(
             child: CircularProgressIndicator(
               value: loadingProgress.expectedTotalBytes != null
                   ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                   : null,
             ),
           );
         },
         errorBuilder: (context, error, stackTrace) {
           return const Text('Failed to load image.');
         },
       );
     }
   }