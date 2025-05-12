import 'package:chip_8_emulator_dart/feature/emulator/view/emulator_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Chip8EmulatorApp());
}

class Chip8EmulatorApp extends StatelessWidget {
  const Chip8EmulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chip-8 Emulator',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        colorScheme: ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.greenAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.greenAccent,
          thumbColor: Colors.greenAccent,
        ),
      ),
      home: EmulatorScreen(),
    );
  }
}
