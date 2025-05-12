class ChipDisplay {
  static const int WIDTH = 64;
  static const int HEIGHT = 32;

  final List<List<bool>> _pixels = List.generate(
    HEIGHT,
    (_) => List.filled(WIDTH, false),
  ); // 64x32-pixel monochrome display, where (0, 0) is located on the top-left
  bool _changed = false;

  void reset() {
    for (var i = 0; i < HEIGHT; i++) {
      for (var j = 0; j < WIDTH; j++) {
        _pixels[i][j] = false;
      }
    }
    _changed = true;
  }

  List<List<bool>> getDisplayBuffer() {
    return _pixels;
  }

  bool setPixel(int x, int y) {
    // Handle wrapping (per Chip-8 spec)
    x = x % WIDTH;
    y = y % HEIGHT;

    // XOR operation
    bool wasSet = _pixels[y][x];
    _pixels[y][x] = !_pixels[y][x];
    _changed = true;

    // Return true if pixel was turned off
    return wasSet && !_pixels[y][x];
  }

  bool hasChanged() {
    bool changed = _changed;
    _changed = false;
    return changed;
  }
}
