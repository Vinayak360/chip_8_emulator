import 'dart:developer';
import 'dart:typed_data';
import 'package:chip_8_emulator_dart/utils/rom_loader.dart';
import 'package:flutter/material.dart';

class ControlPanelWidget extends StatelessWidget {
  final bool isRunning;
  final bool isRomLoaded;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onStep;
  final Function(Uint8List) onLoadRom;
  final Function(int) onSpeedChange;
  final int currentSpeed;
  final RomLoader _romLoader = RomLoader();

  ControlPanelWidget({
    super.key,
    required this.isRunning,
    required this.isRomLoaded,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onStep,
    required this.onLoadRom,
    required this.onSpeedChange,
    required this.currentSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            runSpacing: 16,
            spacing: 16,

            children: [
              _buildControlButton(
                context: context,
                icon: Icons.folder_open,
                label: 'Load ROM',
                onPressed: () => _showRomPickerDialog(context),
                primary: true,
              ),
              _buildControlButton(
                context: context,
                icon: Icons.play_arrow,
                label: 'Start',
                onPressed: isRomLoaded && !isRunning ? onStart : null,
              ),
              _buildControlButton(
                context: context,
                icon: Icons.pause,
                label: 'Pause',
                onPressed: isRunning ? onPause : null,
              ),
              _buildControlButton(
                context: context,
                icon: Icons.refresh,
                label: 'Reset',
                onPressed: isRomLoaded ? onReset : null,
              ),
              _buildControlButton(
                context: context,
                icon: Icons.navigate_next,
                label: 'Step',
                onPressed: isRomLoaded && !isRunning ? onStep : null,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.speed, color: Colors.white70),
              SizedBox(width: 8),
              Text('Speed:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  min: 60,
                  max: 1000,
                  divisions: 19,
                  value: currentSpeed.toDouble(),
                  label: '$currentSpeed Hz',
                  onChanged: (value) => onSpeedChange(value.toInt()),
                  activeColor: Colors.greenAccent,
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  '$currentSpeed Hz',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool primary = false,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(label, style: TextStyle(fontSize: 12)),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? Colors.greenAccent : null,
        foregroundColor: primary ? Colors.black : null,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      ),
    );
  }

  void _showRomPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select a ROM'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._romLoader.getSampleRoms().entries.map(
                    (entry) => ListTile(
                      leading: Icon(Icons.gamepad),
                      title: Text(entry.key),
                      subtitle: Text('Built-in ROM'),
                      onTap: () {
                        onLoadRom(entry.value);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.upload_file),
                    title: Text('Load from File'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final rom = await _romLoader.loadRomFromFilePicker();
                      log("Got the rom $rom");
                      if (rom != null) {
                        onLoadRom(rom);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
