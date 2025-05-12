class Keyboard {
  static const int KEY_COUNT = 16;
  final List<bool> _keys = List.filled(KEY_COUNT, false);

  void reset() {
    for (int i = 0; i < KEY_COUNT; i++) {
      _keys[i] = false;
    }
  }

  bool isKeyPressed(int key) {
    if (key >= 0 && key < KEY_COUNT) {
      return _keys[key];
    }
    return false;
  }

  void keyDown(int key) {
    if (key >= 0 && key < KEY_COUNT) {
      _keys[key] = true;
    }
  }

  void keyUp(int key) {
    if (key >= 0 && key < KEY_COUNT) {
      _keys[key] = false;
    }
  }

  int? getKeyPressed() {
    for (int i = 0; i < KEY_COUNT; i++) {
      if (_keys[i]) {
        return (i);
      }
    }
    return null;
  }
}
