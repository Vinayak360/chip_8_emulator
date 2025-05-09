import 'package:chip_8_emulator_dart/chip_8_core/memory.dart';

class Registers {
  static const int REGISTER_COUNT = 16;

  final List<int> v = List.filled(
    REGISTER_COUNT,
    0,
  ); // V0 - VF registers ( 16 general purpose 8-bit registers)
  int
  indexRegister; //  16-bit register (this register is usually used to store memory addresses (leaving some bits unused, since memory only needs 12 bits).)
  int programCounter; // 16 bits
  // 8 bit
  Registers()
    : indexRegister = 0,
      programCounter = Memory.PROGRAM_START_ADDRESS;
  void reset() {
    indexRegister = 0;
    programCounter = Memory.PROGRAM_START_ADDRESS;
    v.fillRange(0, REGISTER_COUNT, 0);
  }
}
