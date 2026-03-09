import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/shader_loader.dart';

/// Animated plasma blob rendered via a GLSL fragment shader.
///
/// The shader renders a 2D plasma sphere with simplex noise FBM,
/// Fresnel edge glow, and voice-reactive distortion driven by [amplitude].
class PlasmaBlob extends StatefulWidget {
  const PlasmaBlob({
    super.key,
    required this.amplitude,
    this.sizeFraction = 0.38,
  });

  /// A [ValueListenable] providing smoothed mic amplitude (0.0–1.0).
  final ValueListenable<double> amplitude;

  /// Fraction of the shortest screen dimension used as blob diameter.
  final double sizeFraction;

  @override
  State<PlasmaBlob> createState() => _PlasmaBlobState();
}

class _PlasmaBlobState extends State<PlasmaBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentShader? _shader;
  bool _shaderReady = false;

  static const String _shaderPath = 'shaders/plasma_blob.frag';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    final program = await ShaderLoader.load(_shaderPath);
    if (mounted) {
      setState(() {
        _shader = program.fragmentShader();
        _shaderReady = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shaderReady) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, widget.amplitude]),
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final shortSide = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;
              final blobDiameter = shortSide * widget.sizeFraction;

              return Center(
                child: SizedBox(
                  width: blobDiameter,
                  height: blobDiameter,
                  child: CustomPaint(
                    painter: _PlasmaBlobPainter(
                      shader: _shader!,
                      time: _controller.lastElapsedDuration
                              ?.inMilliseconds
                              .toDouble() ??
                          0.0,
                      amplitude: widget.amplitude.value,
                      blobRadius: blobDiameter / 2.0,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlasmaBlobPainter extends CustomPainter {
  _PlasmaBlobPainter({
    required this.shader,
    required this.time,
    required this.amplitude,
    required this.blobRadius,
  });

  final ui.FragmentShader shader;
  final double time;
  final double amplitude;
  final double blobRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // Uniform indices: uTime(0), uResolution(1,2), uAmplitude(3), uBlobRadius(4)
    shader.setFloat(0, time * 0.001); // seconds
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);
    shader.setFloat(3, amplitude);
    shader.setFloat(4, blobRadius);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_PlasmaBlobPainter oldDelegate) => true;
}
