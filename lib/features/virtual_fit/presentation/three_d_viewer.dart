import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/tokens.dart';

enum ViewerMode { sampleGlb, fallback2d, unavailable }

class ThreeDViewer extends StatefulWidget {
  const ThreeDViewer({super.key, this.mode = ViewerMode.sampleGlb});
  final ViewerMode mode;

  @override
  State<ThreeDViewer> createState() => ThreeDViewerState();
}

class ThreeDViewerState extends State<ThreeDViewer> {
  double turn = 0;
  double zoom = 1;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => loading = false);
    });
  }

  void rotate(double amount) => setState(() => turn += amount);
  void setView(String view) => setState(
    () => turn = view == 'front' ? 0 : (view == 'side' ? math.pi / 2 : math.pi),
  );
  void zoomBy(double amount) =>
      setState(() => zoom = (zoom + amount).clamp(.8, 1.65));
  void reset() => setState(() {
    turn = 0;
    zoom = 1;
  });

  @override
  Widget build(BuildContext context) {
    if (widget.mode == ViewerMode.unavailable) {
      return Semantics(
        label: '3D viewer unavailable. Product shopping remains available.',
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.view_in_ar_outlined, size: 48),
              SizedBox(height: 16),
              Text(
                '3D is unavailable on this device',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Use the accessible outfit list and 2D product images instead.',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }
    return Semantics(
      label:
          'Interactive full-body avatar wearing an ivory top and charcoal wide-leg trousers. Rotate, zoom and camera view controls follow.',
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFFF0E8DD), Color(0xFFDCD5CB)],
              ),
            ),
          ),
          if (widget.mode == ViewerMode.fallback2d)
            Image.asset(
              'assets/images/avatar_studio.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            )
          else
            Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .001)
                  ..rotateY(turn)
                  ..scaleByDouble(zoom, zoom, zoom, 1),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/avatar_studio.png',
                  fit: BoxFit.contain,
                  semanticLabel: 'Sample avatar 3D fallback render',
                ),
              ),
            ),
          if (loading)
            Container(
              color: AppColors.canvas.withValues(alpha: .88),
              child: const Center(
                child: SizedBox(
                  width: 240,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(color: AppColors.accent),
                      SizedBox(height: 12),
                      Text('Loading sample garment assets…'),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              color: AppColors.white.withValues(alpha: .92),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Text(
                widget.mode == ViewerMode.sampleGlb
                    ? 'SAMPLE GLB MODE'
                    : '2D FALLBACK',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
