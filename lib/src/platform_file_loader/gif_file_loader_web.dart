import 'dart:typed_data';

Future<Uint8List> loadGifDataFromPath(String path) async {
  // **CRITICAL:** On web, File() is not available.
  throw UnsupportedError(
    'Direct file path access is not supported on web. '
    'Use an Asset or Network URL source.',
  );
}
