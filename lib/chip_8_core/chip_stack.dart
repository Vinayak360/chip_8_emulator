class ChipStack {
  static const int STACK_LEVEL_COUNT = 16;

  final List<int> stack = List.filled(STACK_LEVEL_COUNT, 0);
  int pointer = -1;
  void push({required int value}) {
    if (pointer >= STACK_LEVEL_COUNT) {
      throw IndexError.withLength(
        pointer,
        STACK_LEVEL_COUNT,
        message: "ChipStack-Overflow - Pointer out of range $pointer",
      );
    } else {
      stack[pointer] = value;
      pointer++;
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
      int value = stack.removeAt(pointer);
      pointer--;
      return value;
    }
  }

  int getStackTopValue() {
    return stack[pointer];
  }

  void reset() {
    pointer = -1;
    stack.fillRange(0, STACK_LEVEL_COUNT, 0);
  }
}
