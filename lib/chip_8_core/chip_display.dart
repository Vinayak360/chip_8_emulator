class ChipDisplay {
  static const int WIDTH = 64;
  static const int HEIGHT = 32;

  final List<List<bool>> _pixels = List.generate(
    HEIGHT,
    (_) => List.filled(WIDTH, false),
  ); // 64x32-pixel monochrome display, where (0, 0) is located on the top-left
  void reset() {
    for (var i = 0; i < HEIGHT; i++) {
      for (var j = 0; j < WIDTH; j++) {
        _pixels[i][j] = false;
      }
    }
  }
}
