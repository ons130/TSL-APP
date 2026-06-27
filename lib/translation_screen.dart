import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'app_colors.dart';
import 'permission_helper.dart';
import 'app_drawer.dart';

class TranslationScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final FlutterTts? tts;
  final PermissionHandler? permissionHandler;

  const TranslationScreen({
    super.key,
    required this.cameras,
    this.tts,
    this.permissionHandler,
  });

  @override
  TranslationScreenState createState() => TranslationScreenState();
}

class TranslationScreenState extends State<TranslationScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  String _translatedText = '';
  bool _isProcessing = false;
  bool _permissionGranted = false;
  bool _cameraError = false;
  String _errorMessage = '';
  late FlutterTts _tts;

  // New: Track whether currently recording or not
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _tts = widget.tts ?? FlutterTts();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final status = await (widget.permissionHandler?.requestPermission(Permission.camera) ??
          Permission.camera.request());

      if (status.isGranted) {
        setState(() => _permissionGranted = true);
        _initCamera();
        _initTTS();
      } else {
        setState(() {
          _errorMessage = 'Permission de la caméra refusée. Activez-la dans les paramètres.';
          _cameraError = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de permission: ${e.toString()}';
        _cameraError = true;
      });
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameraController = CameraController(
        widget.cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de caméra: ${e.toString()}';
        _cameraError = true;
      });
    }
  }

  Future<void> _initTTS() async {
    try {
      await _tts.setLanguage('ar-TN'); // Arabic dialect
      await _tts.setSpeechRate(0.5);
      await _tts.awaitSpeakCompletion(true);
    } catch (e) {
      setState(() => _errorMessage = 'Erreur TTS: ${e.toString()}');
    }
  }

  // Updated method to toggle recording start/stop
  Future<void> _captureAndTranslate() async {
    if (_isProcessing || !_isCameraInitialized) return;

    if (!_isRecording) {
      // Start recording
      try {
        await _cameraController.startVideoRecording();
        setState(() {
          _isRecording = true;
          _translatedText = '';
        });
      } catch (e) {
        setState(() {
          _translatedText = 'Erreur démarrage enregistrement: $e';
        });
      }
    } else {
      // Stop recording and process video
      setState(() {
        _isProcessing = true;
        _isRecording = false;
        _translatedText = '';
      });

      try {
        final videoFile = await _cameraController.stopVideoRecording();

        final uri = Uri.parse('http://192.168.0.200:8800/predict'); // backend IP
        final request = http.MultipartRequest('POST', uri);
        request.files.add(await http.MultipartFile.fromPath('video', videoFile.path));
        final streamedResponse = await request.send().timeout(Duration(seconds:60));
        final response = await http.Response.fromStream(streamedResponse);

        final decoded = jsonDecode(response.body);
        if (decoded['prediction'] != null) {
          setState(() => _translatedText = decoded['prediction']);
          await _tts.speak(_translatedText);
        } else {
          setState(() => _translatedText = 'Erreur: ${decoded['error']}');
        }
      } catch (e) {
        setState(() => _translatedText = 'Erreur: $e');
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _speakText() async {
    if (_translatedText.isEmpty) return;
    try {
      await _tts.speak(_translatedText);
    } catch (e) {
      setState(() => _errorMessage = 'Erreur vocale: ${e.toString()}');
    }
  }

  void _retryCamera() {
    setState(() {
      _cameraError = false;
      _errorMessage = '';
    });
    _checkPermissions();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: buildAppDrawer(context),
      appBar: AppBar(
        title: const Text('Traducteur de Langue de Signe'),
      ),
      body: _cameraError
          ? _errorView()
          : !_permissionGranted
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: _isCameraInitialized
                          ? Stack(
                              children: [
                                CameraPreview(_cameraController),
                                if (_isProcessing)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ),
                    _buildTranslationPanel(theme),
                  ],
                ),
    );
  }

  Widget _buildTranslationPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha((0.1*255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogTheme.backgroundColor?.withAlpha((0.1 * 255).toInt()) ?? Colors.grey.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.translate, color: theme.primaryColor),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    _translatedText.isNotEmpty
                        ? _translatedText
                        : 'Capturez un signe pour traduire',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _translatedText.isNotEmpty
                          ? theme.textTheme.bodyMedium!.color
                          : theme.disabledColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueSwatch[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isRecording ? Icons.stop : Icons.videocam),
                label: Text(_isProcessing
                    ? 'Traitement...'
                    : (_isRecording ? 'Arrêter' : 'Enregistrer')),
                onPressed: _isProcessing ? null : _captureAndTranslate,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueSwatch[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                icon: const Icon(Icons.volume_up),
                label: const Text('Parler'),
                onPressed: _translatedText.isEmpty ? null : _speakText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 20),
            const Text(
              'Erreur de Caméra',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              onPressed: _retryCamera,
            ),
            const SizedBox(height: 15),
            if (!_permissionGranted)
              TextButton(
                onPressed: openAppSettings,
                child: const Text('Ouvrir les Paramètres'),
              ),
          ],
        ),
      ),
    );
  }
}
