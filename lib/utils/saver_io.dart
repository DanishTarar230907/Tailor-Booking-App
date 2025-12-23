import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<void> saveFile(Uint8List bytes, String fileName) async {
  Directory? directory;
  if (Platform.isWindows) {
    directory = await getDownloadsDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  
  // Fallback if downloads dir is null
  directory ??= await getApplicationDocumentsDirectory();
  
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(bytes);
  
  // Open the file on Windows/Mac/Linux
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
     Process.run('explorer.exe', [file.path]);
  }
}
