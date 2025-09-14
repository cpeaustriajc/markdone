// Cross-platform export helper. Uses conditional import to pick web or io implementation.
import 'export_helper_io.dart' if (dart.library.html) 'export_helper_web.dart';

/// Saves [content] to [filename].
/// On web this triggers a browser download and returns the object URL.
/// On other platforms it writes to the app documents directory and returns the file path.
Future<String> saveMarkdownFile(String filename, String content) => saveMarkdownFileImpl(filename, content);
