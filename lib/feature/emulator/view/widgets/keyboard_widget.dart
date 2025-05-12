import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Intent for key down action
class KeypadKeyDownIntent extends Intent {
  final int keyIndex;
  const KeypadKeyDownIntent(this.keyIndex);
}

// Intent for key up action
class KeypadKeyUpIntent extends Intent {
  final int keyIndex;
  const KeypadKeyUpIntent(this.keyIndex);
}

// Action for handling key down
class KeypadKeyDownAction extends Action<KeypadKeyDownIntent> {
  final Function(int) onKeyDown;

  KeypadKeyDownAction(this.onKeyDown);

  @override
  Object? invoke(KeypadKeyDownIntent intent) {
    onKeyDown(intent.keyIndex);
    return null;
  }
}

// Action for handling key up
class KeypadKeyUpAction extends Action<KeypadKeyUpIntent> {
  final Function(int) onKeyUp;

  KeypadKeyUpAction(this.onKeyUp);

  @override
  Object? invoke(KeypadKeyUpIntent intent) {
    onKeyUp(intent.keyIndex);
    return null;
  }
}

class KeypadWidget extends StatefulWidget {
  final Function(int) onKeyDown;
  final Function(int) onKeyUp;

  const KeypadWidget({
    super.key,
    required this.onKeyDown,
    required this.onKeyUp,
  });

  @override
  State<KeypadWidget> createState() => _KeypadWidgetState();
}

class _KeypadWidgetState extends State<KeypadWidget> {
  // Keep track of which keys are currently pressed
  final Set<int> _pressedKeys = {};

  // Map of logical keyboard keys to CHIP-8 key indices
  static final Map<LogicalKeyboardKey, int> _keyboardMapping = {
    // Row 1
    LogicalKeyboardKey.digit1: 0x1,
    LogicalKeyboardKey.digit2: 0x2,
    LogicalKeyboardKey.digit3: 0x3,
    LogicalKeyboardKey.digit4: 0xC,
    // Row 2
    LogicalKeyboardKey.keyQ: 0x4,
    LogicalKeyboardKey.keyW: 0x5,
    LogicalKeyboardKey.keyE: 0x6,
    LogicalKeyboardKey.keyR: 0xD,
    // Row 3
    LogicalKeyboardKey.keyA: 0x7,
    LogicalKeyboardKey.keyS: 0x8,
    LogicalKeyboardKey.keyD: 0x9,
    LogicalKeyboardKey.keyF: 0xE,
    // Row 4
    LogicalKeyboardKey.keyZ: 0xA,
    LogicalKeyboardKey.keyX: 0x0,
    LogicalKeyboardKey.keyC: 0xB,
    LogicalKeyboardKey.keyV: 0xF,
  };

  // Get physical key label for a CHIP-8 key
  String _getKeyboardLabel(int chipKey) {
    for (var entry in _keyboardMapping.entries) {
      if (entry.value == chipKey) {
        String keyLabel = entry.key.keyLabel;
        // Make sure the key label is just one character
        return keyLabel.length > 1
            ? keyLabel.substring(keyLabel.length - 1)
            : keyLabel;
      }
    }
    return '';
  }

  // Build mapping for shortcut keys
  Map<ShortcutActivator, Intent> _buildShortcuts() {
    final Map<ShortcutActivator, Intent> shortcuts = {};

    // Add keyboard shortcuts for key down events
    for (var entry in _keyboardMapping.entries) {
      // Key down when pressed
      shortcuts[LogicalKeySet(entry.key)] = KeypadKeyDownIntent(entry.value);
    }

    return shortcuts;
  }

  // Focus node to capture keyboard events
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Helper method to build a row of keypad buttons
  Widget _buildKeypadRow(List<int> keyValues, BoxConstraints constraints) {
    // Calculate button size to fit the available width
    final buttonWidth = (constraints.maxWidth / 4) - 8;
    final buttonHeight = (constraints.maxHeight / 4) - 8;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          keyValues.map((keyValue) {
            return SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _pressedKeys.add(keyValue);
                  });
                  widget.onKeyDown(keyValue);
                },
                onTapUp: (_) {
                  setState(() {
                    _pressedKeys.remove(keyValue);
                  });
                  widget.onKeyUp(keyValue);
                },
                onTapCancel: () {
                  setState(() {
                    _pressedKeys.remove(keyValue);
                  });
                  widget.onKeyUp(keyValue);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _pressedKeys.contains(keyValue)
                            ? Colors.greenAccent
                            : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Main key value
                      Center(
                        child: Text(
                          _getKeyLabel(keyValue),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Keyboard mapping hint
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Text(
                          _getKeyboardLabel(keyValue),
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create shortcut mappings
    final shortcuts = _buildShortcuts();

    // Create actions
    final actions = <Type, Action<Intent>>{
      KeypadKeyDownIntent: KeypadKeyDownAction(widget.onKeyDown),
      KeypadKeyUpIntent: KeypadKeyUpAction(widget.onKeyUp),
    };

    // Get screen dimensions to adapt layout
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.shortestSide < 400;

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  // Ensure focus is maintained when clicking on the widget
                  _focusNode.requestFocus();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSmallScreen) // Hide this text on very small screens
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'Click buttons or use keyboard',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        ),
                      ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Create a fixed layout with columns and rows instead of GridView
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Row 1: 1, 2, 3, C
                              _buildKeypadRow([
                                0x1,
                                0x2,
                                0x3,
                                0xC,
                              ], constraints),
                              // Row 2: 4, 5, 6, D
                              _buildKeypadRow([
                                0x4,
                                0x5,
                                0x6,
                                0xD,
                              ], constraints),
                              // Row 3: 7, 8, 9, E
                              _buildKeypadRow([
                                0x7,
                                0x8,
                                0x9,
                                0xE,
                              ], constraints),
                              // Row 4: A, 0, B, F
                              _buildKeypadRow([
                                0xA,
                                0x0,
                                0xB,
                                0xF,
                              ], constraints),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Handle key events for both key down and key up
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_keyboardMapping.containsKey(event.logicalKey)) {
      return KeyEventResult.ignored;
    }

    final chipKey = _keyboardMapping[event.logicalKey]!;

    if (event is KeyDownEvent) {
      // Only trigger key down if it wasn't already pressed
      if (!_pressedKeys.contains(chipKey)) {
        setState(() {
          _pressedKeys.add(chipKey);
        });
        widget.onKeyDown(chipKey);
      }
      return KeyEventResult.handled;
    } else if (event is KeyUpEvent) {
      setState(() {
        _pressedKeys.remove(chipKey);
      });
      widget.onKeyUp(chipKey);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  String _getKeyLabel(int index) {
    const keyMap = {
      0x0: '0',
      0x1: '1',
      0x2: '2',
      0x3: '3',
      0x4: '4',
      0x5: '5',
      0x6: '6',
      0x7: '7',
      0x8: '8',
      0x9: '9',
      0xA: 'A',
      0xB: 'B',
      0xC: 'C',
      0xD: 'D',
      0xE: 'E',
      0xF: 'F',
    };

    return keyMap[index] ?? '';
  }
}
