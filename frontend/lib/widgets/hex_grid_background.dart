import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/shader_loader.dart';

/// Full-screen animated hex grid background rendered via a GLSL fragment shader.
///
/// The shader draws a hex grid with a radial visibility mask (invisible at
/// center, visible at edges) and a repeating teal pulse wave radiating outward.
class HexGridBackground extends StatefulWidget {
  const HexGridBackground({super.key});

  @override
  State<HexGridBackground> createState() => _HexGridBackgroundState();
}

class _HexGridBackgroundState extends State<HexGridBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentShader? _shader;
  bool _shaderReady = false;

  static const String _shaderPath = 'shaders/hex_grid.frag';

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
      return const ColoredBox(color: Colors.black);
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _HexGridPainter(
              shader: _shader!,
              time: _controller.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0.0,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _HexGridPainter extends CustomPainter {
  _HexGridPainter({required this.shader, required this.time});

  final ui.FragmentShader shader;
  final double time;

  @override
  void paint(Canvas canvas, Size size) {
    // Set uniforms: uTime (index 0), uResolution (index 1,2)
    shader.setFloat(0, time * 0.06); // scale time for pulse speed
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_HexGridPainter oldDelegate) => true;
}
