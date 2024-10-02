import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc_observer.dart';
import 'bloc/image_generation/image_generation_bloc.dart';
import 'bloc/object_removal/object_removal_bloc.dart';
import 'bloc/object_cutter/object_cutter_bloc.dart'; // Import the ObjectCutterBloc
import 'services/api_service.dart';
import 'screens/home_screen.dart';

void main() {
  Bloc.observer = AppBlocObserver();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ImageGenerationBloc>(
          create: (context) => ImageGenerationBloc(
            apiService: ApiService(baseUrl: 'http://127.0.0.1:5000'),
          ),
        ),
        BlocProvider<ObjectRemovalBloc>(
          create: (context) => ObjectRemovalBloc(
            apiService: ApiService(baseUrl: 'http://127.0.0.1:5000'),
          ),
        ),
        BlocProvider<ObjectCutterBloc>(
          create: (context) => ObjectCutterBloc(
            apiService: ApiService(baseUrl: 'http://127.0.0.1:5000'),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karios Creations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}





























// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'bloc/bloc_observer.dart';
// import 'bloc/image_generation/image_generation_bloc.dart';
// import 'bloc/object_removal/object_removal_bloc.dart';
// import 'services/api_service.dart';
// import 'screens/home_screen.dart';

// void main() {
//   Bloc.observer = AppBlocObserver();

//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider<ImageGenerationBloc>(
//           create: (context) => ImageGenerationBloc(
//                  apiService: ApiService(baseUrl: 'http://192.168.100.121:5000'),
//           ),
//         ),
//         BlocProvider<ObjectRemovalBloc>(
//           create: (context) => ObjectRemovalBloc(
//                  apiService: ApiService(baseUrl: 'http://192.168.100.121:5000'),
//           ),
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Karios Creations',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }