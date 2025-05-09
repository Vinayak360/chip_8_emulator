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

  void reset() {
    _memory.reset();
    _display.reset();
    _keyboard.reset();
    _timers.reset();
    _registers.reset();
    _stack.reset();
  }

  void cycle() {
    int opcode = _fetchOpcode();
    _decodeAndExecuteOpcode(opcode: opcode);
  }

  int _fetchOpcode() {
    int opcode = _memory.readWord(address: _registers.programCounter);
    _registers.programCounter += 2; // one opcode is 2 bytes long

    return opcode;
  }

  void _decodeAndExecuteOpcode({required int opcode}) {
    // Extract components from opcode
    int x = (opcode & 0x0F00) >> 8;
    int y = (opcode & 0x00F0) >> 4;
    int n = opcode & 0x000F;
    int nn = opcode & 0x00FF;
    int nnn = opcode & 0x0FFF;
    switch (opcode & 0xF000) {
      case 0x00E0:
        if (opcode == 0x00E0) {
          // 00E0: Clears the screen
          _display.reset();
        } else if (opcode == 0x00EE) {
          // 00EE: Return from subroutine
          _registers.programCounter = _stack.pop();
        }
        break;
      case 0x1000:
        // 1NNN: Jump to address NNN
        _registers.programCounter = nnn;
        break;
      default:
        throw UnimplementedError("Not Implemented");
    }
  }
}
