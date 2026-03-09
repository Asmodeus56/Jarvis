import 'package:flutter/material.dart';
import '../services/audio_input_service.dart';
import '../widgets/hex_grid_background.dart';
import '../widgets/plasma_blob.dart';

/// Main screen: layers the hex grid background and the plasma blob.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AudioInputService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioInputService();
    _startAudio();
  }

  Future<void> _startAudio() async {
    await _audioService.start();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: hex grid background (full screen)
          const HexGridBackground(),

          // Layer 2: plasma blob (centered)
          PlasmaBlob(amplitude: _audioService.amplitude),
        ],
      ),
    );
  }
}
