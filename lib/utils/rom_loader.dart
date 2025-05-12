import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;

class RomLoader {
  Future<Uint8List?> loadRomFromAssets(String path) async {
    try {
      ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      log('Error loading ROM from assets: $e');
      return null;
    }
  }

  Future<Uint8List?> loadRomFromFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.single.bytes != null) {
          // Web platform or file bytes available directly
          return result.files.single.bytes;
        } else if (result.files.single.path != null) {
          // Native platforms with file path
          // You would need to use dart:io to read file which isn't available on web
          // This is a placeholder for that implementation
          // throw UnimplementedError(
          //   'File reading from path not implemented in this example',
          // );
          File file = File(result.files.single.path!);
          return file.readAsBytesSync();
        }
      }
      return null;
    } catch (e, s) {
      log('Error loading ROM from file picker:sd $e $s');
      return null;
    }
  }

  // Built-in ROM samples for testing
  Map<String, Uint8List> getSampleRoms() {
    return {
      'IBM Logo': Uint8List.fromList([
        0x00,
        0xE0,
        0xA2,
        0x2A,
        0x60,
        0x0C,
        0x61,
        0x08,
        0xD0,
        0x1F,
        0x70,
        0x09,
        0xA2,
        0x39,
        0xD0,
        0x1F,
        0xA2,
        0x48,
        0x70,
        0x08,
        0xD0,
        0x1F,
        0x70,
        0x04,
        0xA2,
        0x57,
        0xD0,
        0x1F,
        0x70,
        0x08,
        0xA2,
        0x66,
        0xD0,
        0x1F,
        0x70,
        0x08,
        0xA2,
        0x75,
        0xD0,
        0x1F,
        0x12,
        0x28,
        0xFF,
        0x00,
        0xFF,
        0x00,
        0x3C,
        0x00,
        0x3C,
        0x00,
        0x3C,
        0x00,
        0x3C,
        0x00,
        0xFF,
        0x00,
        0xFF,
        0xFF,
        0x00,
        0xFF,
        0x00,
        0x38,
        0x00,
        0x3F,
        0x00,
        0x3F,
        0x00,
        0x38,
        0x00,
        0xFF,
        0x00,
        0xFF,
        0x80,
        0x00,
        0xE0,
        0x00,
        0xE0,
        0x00,
        0x80,
        0x00,
        0x80,
        0x00,
        0xE0,
        0x00,
        0xE0,
        0x00,
        0x80,
        0xF8,
        0x00,
        0xFC,
        0x00,
        0x3E,
        0x00,
        0x3F,
        0x00,
        0x3B,
        0x00,
        0x39,
        0x00,
        0xF8,
        0x00,
        0xF8,
        0x03,
        0x00,
        0x07,
        0x00,
        0x0F,
        0x00,
        0xBF,
        0x00,
        0xFB,
        0x00,
        0xF3,
        0x00,
        0xE3,
        0x00,
        0x43,
        0xE0,
        0x00,
        0xE0,
        0x00,
        0x80,
        0x00,
        0x80,
        0x00,
        0x80,
        0x00,
        0x80,
        0x00,
        0xE0,
        0x00,
        0xE0,
      ]),
    };
  }
}
