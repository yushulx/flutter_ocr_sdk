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
  // 1. Locate executable folder
  final execDir = Directory(p.dirname(Platform.resolvedExecutable));

  // 2. Choose where to extract
  final targetDir =
      Platform.isWindows ? execDir : Directory(p.join(execDir.path, 'lib'));
  targetDir.createSync(recursive: true);

  // 3. Prepare cache in system temp
  final cacheDir =
      Directory(p.join(Directory.systemTemp.path, 'flutter_ocr_sdk'));
  cacheDir.createSync(recursive: true);
  final zipCacheFile = File(p.join(cacheDir.path, _zipName));

  // 4. Download if missing
  if (!zipCacheFile.existsSync()) {
    stdout.writeln('Downloading resources.zip to ${zipCacheFile.path} …');
    final resp = await http.get(Uri.parse(_zipUrl));
    if (resp.statusCode != 200) {
      stderr.writeln('Failed to download ($_zipUrl): HTTP ${resp.statusCode}');
      exit(1);
    }
    zipCacheFile.writeAsBytesSync(resp.bodyBytes);
    stdout.writeln('✅ Cached zip in temp.');
  } else {
    stdout.writeln('✅ Using cached zip: ${zipCacheFile.path}');
  }

  // 5. Extract into targetDir
  final bytes = zipCacheFile.readAsBytesSync();
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

  stdout.writeln('✅ Resources unpacked to: ${targetDir.path}');
}
