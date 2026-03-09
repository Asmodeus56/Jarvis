# JARVIS — AI Assistant

An AI assistant application with an animated, GPU-accelerated plasma core and hex grid background, built with Flutter.

## Project Structure

```
jarvis/
├── frontend/             # Flutter application
│   ├── lib/
│   │   ├── main.dart             # App entry point
│   │   ├── core/
│   │   │   └── jarvis_theme.dart # Theme & color constants
│   │   ├── screens/
│   │   │   └── home_screen.dart  # Main screen layout
│   │   ├── services/
│   │   │   └── audio_input_service.dart  # Mic input & amplitude
│   │   ├── utils/
│   │   │   └── shader_loader.dart        # Shader cache utility
│   │   └── widgets/
│   │       ├── hex_grid_background.dart  # Hex grid shader widget
│   │       └── plasma_blob.dart          # Plasma blob shader widget
│   ├── shaders/
│   │   ├── hex_grid.frag         # Hex grid GLSL fragment shader
│   │   └── plasma_blob.frag      # Plasma blob GLSL fragment shader
│   ├── test/
│   │   └── widget_test.dart      # Widget tests
│   ├── windows/                  # Windows platform runner
│   ├── pubspec.yaml              # Flutter dependencies
│   └── analysis_options.yaml     # Dart analyzer config
├── reference/
│   ├── background.txt            # Reference: hex grid HTML prototype
│   └── blob.txt                  # Reference: plasma blob HTML prototype
└── README.md
```

## Getting Started

### Prerequisites
- Flutter SDK (^3.11.1)
- Windows desktop support enabled

### Run the App
```bash
cd frontend
flutter pub get
flutter run -d windows
```

## Features
- **Plasma Blob** — Voice-reactive plasma sphere with simplex noise FBM, Fresnel edge glow
- **Hex Grid Background** — Animated hexagonal grid with radial visibility mask and teal pulse wave
- **Voice Reactivity** — Real-time microphone input with smoothed amplitude for UI animations
- **GPU Accelerated** — All visuals rendered via GLSL fragment shaders
