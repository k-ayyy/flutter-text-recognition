import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // Control of the lifecycle of the main widget
  bool _isPermissionGranted = false;

  late final Future<void> _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override

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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Text Recognition'),
          ),
          body: Center(
            child: Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Text(
                _isPermissionGranted
                    ? 'Camera permission granted'
                    : 'Camera permission not granted',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
