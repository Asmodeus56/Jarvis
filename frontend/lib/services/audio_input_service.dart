import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

/// Streams smoothed microphone amplitude (0.0–1.0) for voice-reactive UI.
///
/// Uses the `record` package to capture mic input on Windows.
/// Applies exponential moving average for smooth, low-sensitivity output.
class AudioInputService {
  AudioInputService({
    this.smoothingFactor = 0.15,
    this.pollIntervalMs = 33, // ~30 Hz
    this.minDbFS = -60.0,
  });

  final double smoothingFactor;
  final int pollIntervalMs;
  final double minDbFS;

  final ValueNotifier<double> amplitude = ValueNotifier<double>(0.0);

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _pollTimer;
  double _smoothedValue = 0.0;
  bool _isActive = false;

  bool get isActive => _isActive;

  /// Start listening to the microphone.
  Future<void> start() async {
    if (_isActive) return;

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      debugPrint('AudioInputService: Microphone permission denied.');
      return;
    }

    // Start recording to a stream (no file saved).
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        sampleRate: 16000,
      ),
      path: '', // empty path → stream mode on supported platforms
    );

    _isActive = true;

    // Poll amplitude at ~30 Hz.
    _pollTimer = Timer.periodic(
      Duration(milliseconds: pollIntervalMs),
      (_) => _pollAmplitude(),
    );
  }

  Future<void> _pollAmplitude() async {
    try {
      final amp = await _recorder.getAmplitude();
      final dBFS = amp.current;

      // Map dBFS (e.g. -60..0) → 0.0..1.0
      double normalized = ((dBFS - minDbFS) / -minDbFS).clamp(0.0, 1.0);

      // Exponential moving average (EMA) for smoothing
      _smoothedValue =
          _smoothedValue + smoothingFactor * (normalized - _smoothedValue);

      amplitude.value = _smoothedValue;
    } catch (e) {
      // Silently ignore amplitude errors during recording
    }
  }

  /// Stop listening.
  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (_isActive) {
      await _recorder.stop();
      _isActive = false;
    }
    _smoothedValue = 0.0;
    amplitude.value = 0.0;
  }

  /// Release resources.
  Future<void> dispose() async {
    await stop();
    _recorder.dispose();
    amplitude.dispose();
  }
}
