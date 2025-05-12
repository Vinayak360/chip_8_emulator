import 'dart:developer';
import 'dart:typed_data';

class Memory {
  static const int MEMORY_SIZE = 4096;
  static const int PROGRAM_START_ADDRESS = 0x200;

  final Uint8List _memory = Uint8List(MEMORY_SIZE);
  // Font set (0-F) - Each character is 5 bytes
  static const List<int> _fontSet = [
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80, // F
  ];

  Memory() {
    reset();
  }

  void reset() {
    // Clear memory
    _memory.fillRange(0, MEMORY_SIZE, 0);

    // Load font set into memory (typically at address 0)
    for (int i = 0; i < _fontSet.length; i++) {
      _memory[i] = _fontSet[i];
    }
  }

  // Read a byte from memory (1-byte = 8-bits)
  int readByte(int address) {
    if (address < 0 || address >= MEMORY_SIZE) {
      throw RangeError('Memory address out of bounds: $address');
    }
    return _memory[address];
  }

  int readWord({required int address}) {
    // one opcode is 2 bytes long
    int leftByte =
        readByte(address) <<
        8; // left shift since int is 64 bit but we need only 8 bits
    int rightByte = readByte(address + 1);
    return leftByte | rightByte;
  }

  // Load a ROM (byte array) into memory starting at PROGRAM_START_ADDRESS
  void loadROM(Uint8List rom) {
    if (rom.length > MEMORY_SIZE - PROGRAM_START_ADDRESS) {
      throw ArgumentError('ROM too large to fit in memory');
    }

    for (int i = 0; i < rom.length; i++) {
      _memory[PROGRAM_START_ADDRESS + i] = rom[i];
    }
    log("loaded rom $_memory");
  }

  void writeByte(int address, int value) {
    if (address < 0 || address >= MEMORY_SIZE) {
      throw RangeError('Memory address out of bounds: $address');
    }
    _memory[address] = value & 0xFF; // Ensure value is a byte
  }
}
