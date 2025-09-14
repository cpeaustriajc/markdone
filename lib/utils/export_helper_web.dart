// This file intentionally uses `dart:html` for Flutter Web downloads.
// It's only imported on the web via conditional imports.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<String> saveMarkdownFileImpl(String filename, String content) async {
  final bytes = html.Blob([content], 'text/markdown');
  final url = html.Url.createObjectUrlFromBlob(bytes);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  // Optionally revoke the URL later; return it so caller can revoke if desired.
  return url;
}
