    import 'package:flutter/material.dart';
import 'image_generation_screen.dart';
import 'object_removal_screen.dart';
import 'object_cutter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Karios Creations'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Image.asset(
                'assets/images/logo.png', 
                width: 200, 
                height: 300, 
                fit: BoxFit.contain,
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageGenerationScreen()),
                );
              },
              child: const Text('Generate Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ObjectRemovalScreen()),
                );
              },
              child: const Text('Remove Object'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ObjectCutterScreen()),
                );
              },
              child: const Text('Object Cutter'),
            ),
          ],
        ),
      ),
    );
  }
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // // Start of Selection
    // import 'package:flutter/material.dart';
    // import 'image_generation_screen.dart';
    // import 'object_removal_screen.dart';
    // import '../widgets/custom_button.dart';
    
    // class HomeScreen extends StatelessWidget {
    //   const HomeScreen({super.key});
    
    //   @override
    //   Widget build(BuildContext context) {
    //     return Scaffold(
    //       appBar: AppBar(
    //         title: const Text('Karios Creations', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
            
    //       ),
    //       body: Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Container(
    //               height: 500,
    //               width: 200,
    //               decoration: BoxDecoration(
    //                 image: DecorationImage(
    //                   image: AssetImage('assets/images/logo.png'),
    //                   fit: BoxFit.contain,
    //                 ),
    //               ),
    //             ),
    //             const SizedBox(height: 5),
    //             CustomButton(
    //               text: 'Generate Image',
    //               onPressed: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(builder: (context) => const ImageGenerationScreen()),
    //                 );
    //               },
    //             ),
    //             const SizedBox(height: 20),
    //             CustomButton(
    //               text: 'Remove Object',
    //               onPressed: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(builder: (context) => const ObjectRemovalScreen()),
    //                 );
    //               },
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   }
    // }