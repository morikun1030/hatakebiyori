// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadJson(String jsonContent, String filename) {
  final blob = html.Blob([jsonContent], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
