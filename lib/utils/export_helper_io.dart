import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> saveMarkdownFileImpl(String filename, String content) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content, flush: true);
  return file.path;
}
