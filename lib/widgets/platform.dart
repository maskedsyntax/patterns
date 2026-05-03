import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

bool get kIsDesktop {
  if (kIsWeb) return false;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
