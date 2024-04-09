import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Recorder'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _startRecording(context);
          },
          child: const Text('Record Video'),
        ),
      ),
    );
  }

  Future<void> _startRecording(BuildContext context) async {
    // Get the list of available cameras
    final cameras = await availableCameras();

    // Select the back camera
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    // Create a CameraController
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    // Initialize the camera
    await controller.initialize();

    // Start recording video
    const videoPath = '/path/to/save/video.mp4';
    await controller.startVideoRecording();

    // Wait for 5 seconds
    await Future.delayed(const Duration(seconds: 5));

    // Stop recording video
    await controller.stopVideoRecording();
    if (context.mounted) {
      // Show a dialog with the video path
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Video Recorded'),
          content: const Text('Video saved at $videoPath'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    // Dispose the camera controller
    controller.dispose();
  }
}
