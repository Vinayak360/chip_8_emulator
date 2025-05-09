import 'dart:async';

class Timers {
  int _delayTimer = 0; // 8-bit registers
  int _soundTimer = 0; // 8-bit registers
  Timer? _timer;
  void Function()? onSound;

  Timers() {
    // Timer ticks at 60Hz (16.67ms)
    _timer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (_delayTimer > 0) {
      _delayTimer--;
    }

    if (_soundTimer > 0) {
      _soundTimer--;

      if (onSound != null) {
        onSound!();
      }
    }
  }

  // Set the delay timer
  void setDelayTimer(int value) {
    _delayTimer = value & 0xFF;
  }

  // Set the sound timer
  void setSoundTimer(int value) {
    _soundTimer = value & 0xFF;
  }

  // Get the current delay timer value
  int getDelayTimer() {
    return _delayTimer;
  }

  // Get the current sound timer value
  int getSoundTimer() {
    return _soundTimer;
  }

  // Dispose of the timer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    _delayTimer = 0;
    _soundTimer = 0;
  }
}
