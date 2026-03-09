import 'dart:ui' as ui;

/// Caches compiled [ui.FragmentProgram] instances so shaders are
/// loaded and compiled exactly once across the app's lifetime.
class ShaderLoader {
  ShaderLoader._();

  static final Map<String, ui.FragmentProgram> _cache = {};

  /// Loads a shader from the asset [path] (e.g. 'shaders/plasma_blob.frag').
  /// Returns the cached program on subsequent calls.
  static Future<ui.FragmentProgram> load(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }
    final program = await ui.FragmentProgram.fromAsset(path);
    _cache[path] = program;
    return program;
  }

  /// Returns a cached program synchronously, or null if not yet loaded.
  static ui.FragmentProgram? getCached(String path) => _cache[path];
}
