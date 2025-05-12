import 'dart:math';

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
    _registers.programCounter += 2;

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
      case 0x0000:
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

      case 0x2000:
        // 2NNN: Calls subroutine at NNN
        _stack.push(value: _registers.programCounter);
        _registers.programCounter = nnn;
        break;

      case 0x3000:
        // 3XNN: Skips the next instruction if VX equals NN
        if (_registers.v[x] == nn) {
          _registers.programCounter += 2;
        }
        break;

      case 0x4000:
        // 4XNN: Skips the next instruction if VX does not equal NN
        if (_registers.v[x] != nn) {
          _registers.programCounter += 2;
        }
        break;
      case 0x5000:
        // 5XY0: Skips the next instruction if VX equals VY
        if (_registers.v[x] == _registers.v[y]) {
          _registers.programCounter += 2;
        }
        break;

      case 0x6000:
        // 6XNN: set the register VX to the value NN
        _registers.v[x] = nn;
        break;

      case 0x7000:
        // 7XNN : Add the value NN to VX
        _registers.v[x] = (_registers.v[x] + nn) & 0xFF;
        break;

      case 0x8000:
        switch (n) {
          case 0x0:
            // 8XY0	Assig	Vx = Vy	Sets VX to the value of VY
            _registers.v[x] = _registers.v[y];
            break;

          case 0x1:
            // 8XY1	BitOp	Vx |= Vy	Sets VX to VX or VY
            _registers.v[x] |= _registers.v[y];
            break;

          case 0x2:
            // 8XY2	BitOp	Vx &= Vy	Sets VX to VX and VY
            _registers.v[x] &= _registers.v[y];
            break;

          case 0x3:
            // 8XY3	BitOp	Vx ^= Vy	Sets VX to VX xor VY
            _registers.v[x] ^= _registers.v[y];
            break;

          case 0x4:
            // 8XY4	Math	Vx += Vy	Adds VY to VX. VF is set to 1 when there's an overflow, and to 0 when ther is not
            int sum = _registers.v[x] + _registers.v[y];
            _registers.v[0xF] = sum > 255 ? 1 : 0;
            _registers.v[x] = sum & 0xFF;
            break;

          case 0x5:
            // 8XY5	Math	Vx -= Vy	VY is subtracted from VX. VF is set to 0 when there's an underflow, and 1 when there is not. (i.e. VF set to 1 if VX >= VY and 0 if not)
            int diff = _registers.v[x] - _registers.v[y];
            if (_registers.v[x] >= _registers.v[y]) {
              _registers.v[0xF] = 1;
            } else {
              _registers.v[0xF] = 0;
            }
            _registers.v[x] = diff & 0xFF;
            break;

          case 0x6:
            // 8XY6	BitOp	Vx >>= 1	Shifts VX to the right by 1, then stores the least significant bit of VX prior to the shift into VF
            _registers.v[0xF] = _registers.v[x] & 0x1;
            _registers.v[x] = _registers.v[x] >> 1;
            break;

          case 0x7:
            // 8XY7	Math	Vx = Vy - Vx	Sets VX to VY minus VX. VF is set to 0 when there's an underflow, and 1 when there is not. (i.e. VF set to 1 if VY >= VX)
            int diff = _registers.v[y] - _registers.v[x];
            if (_registers.v[y] >= _registers.v[x]) {
              _registers.v[0xF] = 1;
            } else {
              _registers.v[0xF] = 0;
            }
            _registers.v[x] = diff & 0xFF;
            break;

          case 0XE:
            // 8XYE[a]	BitOp	Vx <<= 1	Shifts VX to the left by 1, then sets VF to 1 if the most significant bit of VX prior to that shift was set, or to 0 if it was unset
            _registers.v[0xF] = (_registers.v[x] >> 7) & 0x1; // Store MSB in VF
            _registers.v[x] = (_registers.v[x] << 1) & 0xFF;
            break;

          default:
            throw UnimplementedError(
              "Not Implemented ${opcode.toRadixString(16).toUpperCase()} ${(opcode & 0xF000).toRadixString(16).toUpperCase()}",
            );
        }
        break;

      case 0x9000:
        // 9XY0	Cond	if (Vx != Vy)	Skips the next instruction if VX does not equal VY.
        if (_registers.v[x] != _registers.v[y]) {
          _registers.programCounter += 2;
        }
        break;

      case 0xA000:
        // ANNN : sets the index register I to the value NNN.
        _registers.indexRegister = nnn;
        break;

      case 0xB000:
        // BNNN	Flow	PC = V0 + NNN	Jumps to the address NNN plus V0
        _registers.programCounter = _registers.v[0] + nnn;
        break;

      case 0xC000:
        // CXNN	Rand	Vx = rand() & NN	Sets VX to the result of a bitwise and operation on a random number (Typically: 0 to 255) and NN
        _registers.v[x] = Random().nextInt(256) & nn;
        break;

      case 0xD000:

        // DXYN: ChipDisplay n-byte sprite at coords (VX, VY)
        int xCoord = _registers.v[x] % ChipDisplay.WIDTH;
        int yCoord = _registers.v[y] % ChipDisplay.HEIGHT;
        _registers.v[0xF] = 0; // Reset collision flag

        for (int row = 0; row < n; row++) {
          if (yCoord + row >= ChipDisplay.HEIGHT) break;

          int sprite = _memory.readByte(_registers.indexRegister + row);

          for (int col = 0; col < 8; col++) {
            if (xCoord + col >= ChipDisplay.WIDTH) break;

            // Check if the current pixel in the sprite is set
            if ((sprite & (0x80 >> col)) != 0) {
              // If this causes a pixel to be flipped from set to unset, set VF
              if (_display.setPixel(xCoord + col, yCoord + row)) {
                _registers.v[0xF] = 1;
              }
            }
          }
        }

        break;

      case 0xE000:
        if (nn == 0x9E) {
          // EX9E	KeyOp	if (key() == Vx)	Skips the next instruction if the key stored in VX(only consider the lowest nibble) is pressed (usually the next instruction is a jump to skip a code block).
          if (_keyboard.isKeyPressed(_registers.v[x])) {
            _registers.programCounter += 2;
          }
        } else if (nn == 0xA1) {
          // EXA1	KeyOp	if (key() != Vx)	Skips the next instruction if the key stored in VX(only consider the lowest nibble) is not pressed (usually the next instruction is a jump to skip a code block).
          if (!_keyboard.isKeyPressed(_registers.v[x])) {
            _registers.programCounter += 2;
          }
        }
        break;

      case 0xF000:
        switch (nn) {
          case 0x07:
            // FX07	Timer	Vx = get_delay()	Sets VX to the value of the delay timer
            _registers.v[x] = _timers.getDelayTimer();
            break;

          case 0x0A:
            // FX0A	KeyOp	Vx = get_key()	A key press is awaited, and then stored in VX (blocking operation, all instruction halted until next key event, delay and sound timers should continue processing)

            int? key = _keyboard.getKeyPressed();
            if (key != null) {
              _registers.v[x] = key;
            } else {
              _registers.programCounter -= 2;
            }
            break;

          case 0x15:
            // FX15	Timer	delay_timer(Vx)	Sets the delay timer to VX
            _timers.setDelayTimer(_registers.v[x]);
            break;

          case 0x18:
            // FX18	Sound	sound_timer(Vx)	Sets the sound timer to VX
            _timers.setSoundTimer(_registers.v[x]);
            break;

          case 0x1E:
            // FX1E	MEM	I += Vx	Adds VX to I. VF is not affected
            _registers.indexRegister += _registers.v[x];
            break;

          case 0x29:
            // FX29	MEM	I = sprite_addr[Vx]	Sets I to the location of the sprite for the character in VX(only consider the lowest nibble). Characters 0-F (in hexadecimal) are represented by a 4x5 font.
            _registers.indexRegister = _registers.v[x] * 5;
            break;

          case 0x33:
            // FX33	BCD
            // set_BCD(Vx)
            // *(I+0) = BCD(3);
            // *(I+1) = BCD(2);
            // *(I+2) = BCD(1);
            // Stores the binary-coded decimal representation of VX, with the hundreds digit in memory at location in I, the tens digit at location I+1, and the ones digit at location I+2
            int value = _registers.v[x];
            _memory.writeByte(
              _registers.indexRegister + 2,
              value % 10,
            ); // Ones place
            value ~/= 10;
            _memory.writeByte(
              _registers.indexRegister + 1,
              value % 10,
            ); // Tens place
            value ~/= 10;
            _memory.writeByte(
              _registers.indexRegister,
              value % 10,
            ); // Hundreds place

            break;

          case 0x55:
            // FX55	MEM	reg_dump(Vx, &I)	Stores from V0 to VX (including VX) in memory, starting at address I. The offset from I is increased by 1 for each value written, but I itself is left unmodified
            for (int i = 0; i <= x; i++) {
              _memory.writeByte(_registers.indexRegister + i, _registers.v[i]);
            }
            break;

          case 0x65:
            // FX65	MEM	reg_load(Vx, &I)	Fills from V0 to VX (including VX) with values from memory, starting at address I. The offset from I is increased by 1 for each value read, but I itself is left unmodified
            for (int i = 0; i <= x; i++) {
              _registers.v[i] = _memory.readByte(_registers.indexRegister + i);
            }
            break;
        }
        break;

      default:
        throw UnimplementedError(
          "Not Implemented ${opcode.toRadixString(16).toUpperCase()} ${(opcode & 0xF000).toRadixString(16).toUpperCase()}",
        );
    }
  }

  void step() {
    cycle();
  }
}
