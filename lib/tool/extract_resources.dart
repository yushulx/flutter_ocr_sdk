import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

/// URL of the zip file
const _zipUrl =
    'https://github.com/yushulx/flutter_ocr_sdk/releases/download/v2.0.0/resources.zip';

/// Name for the downloaded zip cache
const _zipName = 'resources.zip';

Future<void> download() async {
  // Find the folder where the running executable lives:
  final execDir = p.dirname(Platform.resolvedExecutable);
  final targetDir = Directory(execDir);

  // Ensure we have a local copy of the zip:
  final zipFile = File(p.join(targetDir.path, _zipName));
  if (!zipFile.existsSync()) {
    stdout.writeln('🚧 Downloading resources.zip …');
    final resp = await http.get(Uri.parse(_zipUrl));
    if (resp.statusCode != 200) {
      stderr.writeln('Failed to download ($_zipUrl): HTTP ${resp.statusCode}');
      exit(1);
    }
    zipFile.writeAsBytesSync(resp.bodyBytes);
  }

  // Decode & extract:
  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    final outPath = p.join(targetDir.path, file.name);
    if (file.isFile) {
      final outFile = File(outPath);
      outFile.createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(outPath).createSync(recursive: true);
    }
  }

  // Delete the ZIP after successful extraction:
  try {
    zipFile.deleteSync();
    stdout.writeln('🗑️ Deleted ${zipFile.path}');
  } catch (e) {
    stderr.writeln('⚠️ Could not delete ${zipFile.path}: $e');
  }

  stdout.writeln('✅ Resources unpacked to: ${targetDir.path}');
}
