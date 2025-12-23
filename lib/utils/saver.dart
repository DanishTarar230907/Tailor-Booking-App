import 'dart:typed_data';
import 'saver_stub.dart' as saver_impl
    if (dart.library.html) 'saver_web.dart'
    if (dart.library.io) 'saver_io.dart';

Future<void> saveFile(Uint8List bytes, String fileName) => saver_impl.saveFile(bytes, fileName);
