import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class ReportExportSaver {
  static const MethodChannel _macChannel = MethodChannel('patterns/file_export');

  static Future<bool> save(
    Uint8List bytes,
    String filename,
  ) async {
    if (Platform.isMacOS) {
      final result = await _macChannel.invokeMethod<Object?>('saveFile', {
        'dialogTitle': 'Save Patterns Report',
        'fileName': filename,
        'bytes': bytes,
      });
      return result is String && result.isNotEmpty;
    }

    // Desktop (Windows/Linux) and mobile (iOS/Android) all use the platform
    // save dialog. On Android/iOS this is the system "Save to…" sheet where
    // the user picks a real, accessible location (Downloads, Drive, etc.);
    // passing `bytes` is required for the file to be written on mobile.
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Patterns Report',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      bytes: bytes,
    );
    return path != null;
  }
}
