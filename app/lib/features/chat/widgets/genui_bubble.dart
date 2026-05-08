import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

class GenuiBubble extends StatelessWidget {
  const GenuiBubble({
    super.key,
    required this.surfaceId,
    required this.controller,
  });

  final String surfaceId;
  final SurfaceController controller;

  @override
  Widget build(BuildContext context) {
    return Surface(
      surfaceContext: controller.contextFor(surfaceId),
      defaultBuilder: (_) => const SizedBox.shrink(),
    );
  }
}
