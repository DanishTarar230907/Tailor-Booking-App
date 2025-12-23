import 'dart:html' as html;
import 'dart:typed_data';

Future<void> saveFile(Uint8List bytes, String fileName) async {
  try {
    final blob = html.Blob([bytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..style.display = 'none';
    
    html.document.body?.append(anchor);
    anchor.click();
    
    // Clean up
    await Future.delayed(const Duration(milliseconds: 100));
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error in web saver: $e');
    rethrow;
  }
}
