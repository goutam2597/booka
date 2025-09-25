import 'dart:typed_data';

class BrandingCache {
  static final Map<String, Uint8List> _bytesByType = <String, Uint8List>{};
  static final Map<String, String> _urlByType = <String, String>{};

  static Uint8List? getBytes(String type) => _bytesByType[type];
  static String? getUrl(String type) => _urlByType[type];

  static void set(String type, String url, Uint8List bytes) {
    _urlByType[type] = url;
    _bytesByType[type] = bytes;
  }

  static void clear(String type) {
    _urlByType.remove(type);
    _bytesByType.remove(type);
  }
}
