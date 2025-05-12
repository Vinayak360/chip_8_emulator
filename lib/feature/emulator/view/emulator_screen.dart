import 'package:chip_8_emulator_dart/feature/emulator/view/widgets/control_panel_widget.dart';
import 'package:chip_8_emulator_dart/feature/emulator/view/widgets/display_widget.dart';
import 'package:chip_8_emulator_dart/feature/emulator/view/widgets/keyboard_widget.dart';
import 'package:chip_8_emulator_dart/feature/emulator/viewmodel/emulator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmulatorScreen extends StatelessWidget {
  const EmulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmulatorViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chip-8 Emulator'),
          backgroundColor: Colors.grey[900],
        ),
        body: Container(color: Colors.grey[850], child: const _EmulatorBody()),
      ),
    );
  }
}

class _EmulatorBody extends StatelessWidget {
  const _EmulatorBody();

  @override
  Widget build(BuildContext context) {
    // Get the current orientation
    final orientation = MediaQuery.of(context).orientation;

    return Consumer<EmulatorViewModel>(
      builder: (context, viewModel, child) {
        // Error message widget that appears at the top regardless of orientation
        final errorWidget =
            viewModel.errorMessage.isNotEmpty
                ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[400],
                  child: Text(
                    viewModel.errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
                : const SizedBox.shrink();

        // Control panel widget
        final controlPanel = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ExpansionTile(
            title: const Text("Control Panel"),
            shape: Border(),
            backgroundColor: Colors.black,
            children: [
              ControlPanelWidget(
                isRunning: viewModel.isRunning,
                isRomLoaded: viewModel.isRomLoaded,
                onStart: viewModel.start,
                onPause: viewModel.pause,
                onReset: viewModel.reset,
                onStep: viewModel.step,
                onLoadRom: viewModel.loadROM,
                onSpeedChange: viewModel.setSpeed,
                currentSpeed: viewModel.speed,
              ),
            ],
          ),
        );

        // Emulator display widget
        final displayWidget = Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DisplayWidget(
              displayBuffer: viewModel.displayBuffer,
              onColor: Colors.greenAccent,
              offColor: Colors.black,
            ),
          ),
        );

        // Virtual keypad widget
        final keypadWidget = KeypadWidget(
          onKeyDown: viewModel.keyDown,
          onKeyUp: viewModel.keyUp,
        );

        // Return different layouts based on orientation
        if (orientation == Orientation.portrait) {
          // Portrait layout: vertical stacking
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                errorWidget,
                controlPanel,
                const SizedBox(height: 16),
                Expanded(flex: 3, child: displayWidget),
                const SizedBox(height: 16),
                Expanded(flex: 4, child: keypadWidget),
              ],
            ),
          );
        } else {
          // Landscape layout: horizontal arrangement
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                errorWidget,
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left side: Display
                      Flexible(flex: 2, child: displayWidget),
                      const SizedBox(width: 16),
                      // Right side: Controls and keypad
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            controlPanel,
                            const SizedBox(height: 8),
                            Expanded(child: keypadWidget),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
