import 'package:flutter/material.dart';
import 'core/jarvis_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JarvisApp());
}

class JarvisApp extends StatelessWidget {
  const JarvisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JARVIS',
      debugShowCheckedModeBanner: false,
      theme: JarvisTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
