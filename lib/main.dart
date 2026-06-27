import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'translation_screen.dart';
import 'app_colors.dart';
import 'permission_helper.dart';
import 'package:flutter/services.dart';
import 'app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); //hide system bar
  try {
    final cameras = await availableCameras();
    runApp(SignLanguageApp(cameras: cameras));
  } catch (error) {
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: AppColors.orangeSwatch[50],
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.orangeSwatch[900]),
                const SizedBox(height: 20),
                const Text(
                  'Échec d\'initialisation de la caméra',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Erreur: Échec d\'initialisation de la caméra',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orangeSwatch[600],
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignLanguageApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  const SignLanguageApp({
    super.key,
    required this.cameras,
  });

  @override
  State<SignLanguageApp> createState() => _SignLanguageAppState();
}

class _SignLanguageAppState extends State<SignLanguageApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traducteur en Langue de Signe Tunisienne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.orangeSwatch,
        scaffoldBackgroundColor: AppColors.orangeSwatch[50],
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.orangeSwatch[500],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueSwatch[500],
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF222222),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blueSwatch[700],
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(
        cameras: widget.cameras,
        tts: FlutterTts(),
        permissionHandler: DefaultPermissionHandler(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final FlutterTts? tts;
  final PermissionHandler? permissionHandler;

  const HomeScreen({
    super.key,
    required this.cameras,
    this.tts,
    this.permissionHandler,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildAppDrawer(context), 
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TranslationScreen(
                  cameras: cameras,
                  tts: tts,
                  permissionHandler: permissionHandler,
                ),
              )
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeSwatch[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text('Commencer le Traducteur'),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangeSwatch[50],
      body: Center(
        child: Text(
          'Échec d\'initialisation de la caméra',
          style: TextStyle(color: AppColors.orangeSwatch[900], fontSize: 20),
        ),
      ),
    );
  }
}
