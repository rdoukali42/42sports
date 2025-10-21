// Conditional export for web utilities
export 'web_utils_io.dart' if (dart.library.html) 'web_utils_web.dart';
