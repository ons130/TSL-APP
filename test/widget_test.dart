import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_flutter_app/main.dart';

// Mock classes for dependencies
class MockCameraController extends Mock implements CameraController {}
class MockFlutterTts extends Mock implements FlutterTts {
  @override
  Future<bool> setLanguage(String? language) async => super.noSuchMethod(
        Invocation.method(#setLanguage, [language]),
        returnValue: Future.value(true),
      ) as Future<bool>;

  @override
  Future<bool> setSpeechRate(double rate) async => super.noSuchMethod(
        Invocation.method(#setSpeechRate, [rate]),
        returnValue: Future.value(true),
      ) as Future<bool>;

  @override
  Future<int> speak(String text) async => super.noSuchMethod(
        Invocation.method(#speak, [text]),
        returnValue: Future.value(1),
      ) as Future<int>;
  
  @override
  Future<bool> awaitSpeakCompletion(bool value) async => super.noSuchMethod(
        Invocation.method(#awaitSpeakCompletion, [value]),
        returnValue: Future.value(true),
      ) as Future<bool>;
}
class MockPermissionHandler extends Mock implements PermissionHandler {}

// Mock camera descriptions
List<CameraDescription> mockCameras = [
  CameraDescription(
    name: 'fake_camera_1',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 90,
  )
];

void main() {
  late MockFlutterTts mockTts;
  late MockPermissionHandler mockPermissionHandler;

  setUp(() {
    mockTts = MockFlutterTts();
    mockPermissionHandler = MockPermissionHandler();
    
    // Setup mock responses with explicit types
    when(mockTts.setLanguage('fr-FR')).thenAnswer((_) async => true);
    when(mockTts.setSpeechRate(0.5)).thenAnswer((_) async => true);
    when(mockPermissionHandler.requestPermission(Permission.camera))
        .thenAnswer((_) async => PermissionStatus.granted);
  });

  testWidgets('App launches and shows initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(SignLanguageApp(
      cameras: mockCameras,
      tts: mockTts,
      permissionHandler: mockPermissionHandler,
    ));
    
    // Verify core UI elements
    expect(find.text('Sign Language Translator'), findsOneWidget);
    expect(find.byType(CameraPreview), findsOneWidget);
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Speak'), findsOneWidget);
  });

  testWidgets('Translate button triggers processing', (WidgetTester tester) async {
    await tester.pumpWidget(SignLanguageApp(
      cameras: mockCameras,
      tts: mockTts,
      permissionHandler: mockPermissionHandler,
    ));
    
    await tester.pumpAndSettle();
    await tester.tap(find.text('Translate'));
    await tester.pump();
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(Text), findsWidgets);
  });

  testWidgets('Speak button triggers TTS', (WidgetTester tester) async {
    await tester.pumpWidget(SignLanguageApp(
      cameras: mockCameras,
      tts: mockTts,
      permissionHandler: mockPermissionHandler,
    ));
    
    await tester.pumpAndSettle();
    
    final state = tester.state<TranslationScreenState>(find.byType(TranslationScreen));
    state.setTranslatedTextForTesting('Hello');
    await tester.pump();
    
    await tester.tap(find.text('Speak'));
    await tester.pump();
    
    verify(mockTts.speak('Hello')).called(1);
  });

  testWidgets('Camera permission handling', (WidgetTester tester) async {
    when(mockPermissionHandler.requestPermission(Permission.camera))
        .thenAnswer((_) async => PermissionStatus.denied);
    
    await tester.pumpWidget(SignLanguageApp(
      cameras: mockCameras,
      tts: mockTts,
      permissionHandler: mockPermissionHandler,
    ));
    
    await tester.pumpAndSettle();
    expect(find.text('Camera permission denied'), findsOneWidget);
  });

  testWidgets('App shows error when TTS fails', (WidgetTester tester) async {
    when(mockTts.speak('Hello')).thenThrow(Exception('TTS error'));
    
    await tester.pumpWidget(SignLanguageApp(
      cameras: mockCameras,
      tts: mockTts,
      permissionHandler: mockPermissionHandler,
    ));
    
    await tester.pumpAndSettle();
    
    final state = tester.state<TranslationScreenState>(find.byType(TranslationScreen));
    state.setTranslatedTextForTesting('Hello');
    await tester.pump();
    
    await tester.tap(find.text('Speak'));
    await tester.pump();
    
    expect(find.text('TTS error'), findsOneWidget);
  });
}