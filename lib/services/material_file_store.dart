import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local filesystem store for Pro "Exposure Material" binaries (loop-tape audio
/// and images). Files live in `<appSupportDir>/materials/`. The database stores
/// only the **relative filename**; callers resolve it to an absolute [File] at
/// use time via [resolve], because the iOS app-container path is not stable
/// across installs/launches.
class MaterialFileStore {
  static const _folder = 'materials';

  static Future<Directory> dir() async {
    final support = await getApplicationSupportDirectory();
    final materials = Directory(p.join(support.path, _folder));
    if (!await materials.exists()) {
      await materials.create(recursive: true);
    }
    return materials;
  }

  /// Copies [sourcePath] into the materials dir under a generated, collision-free
  /// name keeping the given [extension] (no leading dot). Returns the relative
  /// filename to persist in the database.
  static Future<String> save(String sourcePath, String extension) async {
    final materials = await dir();
    final name =
        'm_${DateTime.now().microsecondsSinceEpoch}.${extension.replaceFirst('.', '')}';
    final dest = p.join(materials.path, name);
    await File(sourcePath).copy(dest);
    return name;
  }

  /// Writes raw [bytes] into the materials dir (used when restoring a backup).
  static Future<void> writeBytes(String fileName, List<int> bytes) async {
    final materials = await dir();
    await File(p.join(materials.path, fileName)).writeAsBytes(bytes);
  }

  /// Absolute [File] for a stored [fileName]. May not exist (e.g. media missing
  /// after a metadata-only restore) - callers should check `existsSync()`.
  static Future<File> resolve(String fileName) async {
    final materials = await dir();
    return File(p.join(materials.path, fileName));
  }

  static Future<void> delete(String fileName) async {
    final materials = await dir();
    final file = File(p.join(materials.path, fileName));
    if (await file.exists()) await file.delete();
  }

  /// All stored material files (used to bundle them into a backup zip).
  static Future<List<File>> allFiles() async {
    final materials = await dir();
    return materials.listSync().whereType<File>().toList(growable: false);
  }

  /// Removes every stored material file. Called from "Wipe all data".
  static Future<void> deleteAll() async {
    final materials = await dir();
    if (await materials.exists()) {
      await materials.delete(recursive: true);
    }
  }
}
