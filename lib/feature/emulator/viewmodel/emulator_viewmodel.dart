// lib/src/viewmodel/emulator_viewmodel.dart

import 'dart:async';
import 'dart:developer';
import 'package:chip_8_emulator_dart/chip_8_core/chip_8.dart';
import 'package:chip_8_emulator_dart/chip_8_core/chip_display.dart';
import 'package:flutter/foundation.dart';

class EmulatorViewModel extends ChangeNotifier {
  final Chip8 _chip8 = Chip8();
  bool _isRomLoaded = false;
  String _errorMessage = '';

  // ChipDisplay buffer for the UI
  List<List<bool>> _displayBuffer = List.generate(
    ChipDisplay.HEIGHT,
    (_) => List.filled(ChipDisplay.WIDTH, false),
  );

  // Last update time for FPS calculation
  int _lastUpdateTime = 0;
  int _frameCount = 0;
  int _fps = 0;

  EmulatorViewModel() {
    // Start a timer to update the display buffer and stats
    Timer.periodic(Duration(milliseconds: 16), (timer) {
      _updateDisplayBuffer();
      _updateFPS();
    });
  }

  // Load a ROM from a byte array
  void loadROM(Uint8List rom) {
    try {
      _chip8.loadROM(rom);
      _isRomLoaded = true;
      _errorMessage = '';
      notifyListeners();
    } catch (e, s) {
      log("Error load ROM $e , $s");
      _errorMessage = 'Failed to load ROM: ${e.toString()}';
      notifyListeners();
    }
  }

  // Start the emulator
  void start() {
    if (_isRomLoaded) {
      try {
        _chip8.start();
        _errorMessage = '';
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Failed to start emulator: ${e.toString()}';
        notifyListeners();
      }
    }
  }

  // Pause the emulator
  void pause() {
    try {
      _chip8.pause();
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to pause emulator: ${e.toString()}';
      notifyListeners();
    }
  }

  // Reset the emulator
  void reset() {
    try {
      _chip8.reset();
      _isRomLoaded = false;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reset emulator: ${e.toString()}';
      notifyListeners();
    }
  }

  // Step through a single instruction
  void step() {
    if (_isRomLoaded) {
      try {
        _chip8.step();
        _updateDisplayBuffer();
        _errorMessage = '';
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Failed to step emulator: ${e.toString()}';
        notifyListeners();
      }
    }
  }

  // Set the emulation speed
  void setSpeed(int speed) {
    if (speed < 60) speed = 60; // Minimum speed
    if (speed > 1000) speed = 1000; // Maximum speed

    try {
      _chip8.setClockSpeed(speed);
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to set emulator speed: ${e.toString()}';
      notifyListeners();
    }
  }

  // Handle key press
  void keyDown(int key) {
    _chip8.keyboard.keyDown(key);
  }

  // Handle key release
  void keyUp(int key) {
    _chip8.keyboard.keyUp(key);
  }

  // Update the display buffer for the UI
  void _updateDisplayBuffer() {
    if (_chip8.display.hasChanged()) {
      _displayBuffer = _chip8.display.getDisplayBuffer();
      notifyListeners();
    }
  }

  // Update FPS counter
  void _updateFPS() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    _frameCount++;

    if (currentTime - _lastUpdateTime >= 1000) {
      _fps = _frameCount;
      _frameCount = 0;
      _lastUpdateTime = currentTime;
      notifyListeners();
    }
  }

  // Get the current display buffer
  List<List<bool>> get displayBuffer => _displayBuffer;

  // Is the emulator running?
  bool get isRunning => _chip8.isRunning();

  // Is a ROM loaded?
  bool get isRomLoaded => _isRomLoaded;

  // Get current FPS
  int get fps => _fps;

  // Get current emulation speed
  int get speed => _chip8.getClockSpeed();

  // Get error message
  String get errorMessage => _errorMessage;

  @override
  void dispose() {
    _chip8.dispose();
    super.dispose();
  }
}
