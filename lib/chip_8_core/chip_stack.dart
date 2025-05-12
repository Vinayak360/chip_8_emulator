class ChipStack {
  static const int STACK_LEVEL_COUNT = 16;

  final List<int> stack = List.filled(STACK_LEVEL_COUNT, 0, growable: true);
  int pointer = -1;
  void push({required int value}) {
    if (pointer >= STACK_LEVEL_COUNT) {
      throw IndexError.withLength(
        pointer,
        STACK_LEVEL_COUNT,
        message: "ChipStack-Overflow - Pointer out of range $pointer",
      );
    } else {
      pointer++;
      stack[pointer] = value;
    }
  }

  int pop() {
    if (pointer < 0) {
      throw IndexError.withLength(
        pointer,
        STACK_LEVEL_COUNT,
        message: "ChipStack-UnderFlow - Pointer out of range $pointer",
      );
    } else {
      int value = stack[pointer];
      pointer--;
      return value;
    }
  }

  int getStackTopValue() {
    return stack[pointer];
  }

  void reset() {
    stack.fillRange(0, STACK_LEVEL_COUNT, 0);
    pointer = -1;
  }
}
