import 'dart:async';

import 'package:chip_8_emulator_dart/chip_8_core/chip_display.dart';
import 'package:chip_8_emulator_dart/chip_8_core/chip_stack.dart';
import 'package:chip_8_emulator_dart/chip_8_core/cpu.dart';
import 'package:chip_8_emulator_dart/chip_8_core/keyboard.dart';
import 'package:chip_8_emulator_dart/chip_8_core/memory.dart';
import 'package:chip_8_emulator_dart/chip_8_core/registers.dart';
import 'package:chip_8_emulator_dart/chip_8_core/timers.dart';

class Chip8 {
  late Memory memory;
  late ChipDisplay display;
  late Keyboard keyboard;
  late Timers timers;
  late Registers registers;
  late ChipStack chipStack;

  late CPU cpu;

  // Emulation settings
  int _clockSpeed = 500; // Instructions per second
  Timer? _emulationTimer;
  bool _isRunning = false;

  Chip8() {
    memory = Memory();
    display = ChipDisplay();
    keyboard = Keyboard();
    timers = Timers();
    registers = Registers();
    chipStack = ChipStack();
    cpu = CPU(
      memory: memory,
      display: display,
      keyboard: keyboard,
      timers: timers,
      registers: registers,
      stack: chipStack,
    );
  }

  void reset() {
    // Stop the emulation if it's running
    pause();

    // Reset components
    memory.reset();
    display.reset();
    keyboard.reset();
    timers.reset();
    registers.reset();
    chipStack.reset();
    cpu.reset();
  }

  // Start the emulation
  void start() {
    if (!_isRunning) {
      _isRunning = true;

      // Calculate interval based on clock speed (1000 because we are calculating in milliseconds)
      // time (seconds)= 1/frequency(instructions per second)
      int intervalMs = (1000 / _clockSpeed).round();

      _emulationTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
        timer,
      ) {
        cpu.cycle();
      });
    }
  }

  // Pause the emulation
  void pause() {
    if (_isRunning) {
      _isRunning = false;
      _emulationTimer?.cancel();
      _emulationTimer = null;
    }
  }

  // Set the clock speed (instructions per second)
  void setClockSpeed(int speed) {
    _clockSpeed = speed;

    // If the emulator is running, restart with the new speed
    if (_isRunning) {
      pause();
      start();
    }
  }

  int getClockSpeed() {
    return _clockSpeed;
  }

  bool isRunning() {
    return _isRunning;
  }

  void dispose() {
    pause();
    timers.dispose();
  }
}
