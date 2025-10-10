import 'dart:io' show File;
import 'dart:typed_data';

Future<Uint8List> loadGifDataFromPath(String path) async {
  try {
    var file = File(path);
    if (file.existsSync()) {
      return await file.readAsBytes();
    } else {
      throw 'file does not exists!';
    }
  } catch (e) {
    rethrow;
  }
}
