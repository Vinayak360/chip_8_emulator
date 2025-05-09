import 'package:chip_8_emulator_dart/chip_8_core/chip_display.dart';
import 'package:chip_8_emulator_dart/chip_8_core/chip_stack.dart';
import 'package:chip_8_emulator_dart/chip_8_core/keyboard.dart';
import 'package:chip_8_emulator_dart/chip_8_core/memory.dart';
import 'package:chip_8_emulator_dart/chip_8_core/registers.dart';
import 'package:chip_8_emulator_dart/chip_8_core/timers.dart';

class CPU {
  final Memory _memory;
  final ChipDisplay _display;
  final Keyboard _keyboard;
  final Timers _timers;
  final Registers _registers;
  final ChipStack _stack;

  CPU({
    required Memory memory,
    required ChipDisplay display,
    required Keyboard keyboard,
    required Timers timers,
    required Registers registers,
    required ChipStack stack,
  }) : _memory = memory,
       _display = display,
       _keyboard = keyboard,
       _timers = timers,
       _registers = registers,
       _stack = stack {
    reset();
  }

  void reset() {}
}
