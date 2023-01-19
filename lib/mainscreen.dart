import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:text_recognition_flutter/result_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // Control of the lifecycle of the main widget
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;

  final _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _stopCamera();
    _textRecognizer.close();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeLifecycleStatus(AppLifecycleState state) {
    // Control camera flow
    // if the camera is no longer in the foreground
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

// private method for handling camera request permission
  Future<void> _requestCameraPermission() async {
    final permissionStatus = await Permission.camera.request();
    _isPermissionGranted = permissionStatus == PermissionStatus.granted;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Stack(
          children: [
            // show camera feed behind everything
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                  future:
                      availableCameras(), // aspect ratio same as the mobile screen
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _initCameraController(snapshot.data!);

                      return Center(child: CameraPreview(_cameraController!));
                    } else {
                      return const LinearProgressIndicator();
                    }
                  }),

            Scaffold(
              appBar: AppBar(
                title: const Text('Recognize Text'),
              ),
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Center(
                              child: ElevatedButton(
                                  onPressed: _scanImage,
                                  child: const Text('Scan Text'))),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                      ),
                      child: const Text(
                        "Camera permission denied",
                        textAlign: TextAlign.center,
                      ),
                    )),
            ),
          ],
        );
      },
    );
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    // _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription currentCamera = cameras[i];
      if (currentCamera.lensDirection == CameraLensDirection.back) {
        camera = currentCamera;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  // Method camera selected
  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    ); // resolution preset set to max helps in text detection
    await _cameraController?.initialize();
    // refreshing of the stated
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();
      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      await navigator.push(MaterialPageRoute(
          builder: (context) => ResultScreen(text: recognizedText.text)));
    } catch (e) {
      print(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while scanning the text"),
        ),
      );
    }
  }
}
