import 'package:chip_8_emulator_dart/chip_8_core/chip_display.dart';
import 'package:flutter/material.dart';

class DisplayWidget extends StatelessWidget {
  final List<List<bool>> displayBuffer;
  final Color onColor;
  final Color offColor;

  const DisplayWidget({
    super.key,
    required this.displayBuffer,
    this.onColor = Colors.greenAccent,
    this.offColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ChipDisplay.WIDTH / ChipDisplay.HEIGHT,
      child: CustomPaint(
        painter: DisplayPainter(
          displayBuffer: displayBuffer,
          onColor: onColor,
          offColor: offColor,
        ),
      ),
    );
  }
}

class DisplayPainter extends CustomPainter {
  final List<List<bool>> displayBuffer;
  final Color onColor;
  final Color offColor;

  DisplayPainter({
    required this.displayBuffer,
    required this.onColor,
    required this.offColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double pixelWidth = size.width / ChipDisplay.WIDTH;
    final double pixelHeight = size.height / ChipDisplay.HEIGHT;

    // Fill the background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = offColor,
    );

    // Draw the pixels
    for (int y = 0; y < ChipDisplay.HEIGHT; y++) {
      for (int x = 0; x < ChipDisplay.WIDTH; x++) {
        if (displayBuffer[y][x]) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * pixelWidth,
              y * pixelHeight,
              pixelWidth,
              pixelHeight,
            ),
            Paint()..color = onColor,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(DisplayPainter oldDelegate) {
    return true;
  }
}
