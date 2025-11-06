
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewer extends StatelessWidget {
  final String modelUrl;

  const ARViewer({super.key, required this.modelUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D Model Viewer")),
      body: Center(
        child: ModelViewer(
          src: modelUrl,
          alt: "3D model of the product",
          ar: true,
          autoRotate: true,
          cameraControls: true,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
