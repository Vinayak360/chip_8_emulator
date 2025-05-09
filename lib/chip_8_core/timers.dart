class Timers {
  int _delayTimer = 0; // 8-bit registers
  int _soundTimer = 0; // 8-bit registers

  void reset() {
    _delayTimer = 0;
    _soundTimer = 0;
  }
}
