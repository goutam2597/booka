import 'dart:typed_data';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/network_service/core/basic_service.dart';
import 'package:bookapp_customer/utils/branding_cache.dart';
import 'package:bookapp_customer/utils/shared_prefs_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkAppLogo extends StatelessWidget {
  final double width;
  final double height;
  // type: 'logo' (default) or 'favicon'
  final String type;
  const NetworkAppLogo({
    super.key,
    required this.width,
    required this.height,
    this.type = 'logo',
  });

  Future<({String url, Uint8List bytes})?> _load() async {
    try {
      final url = await BasicService.getBrandingUrl(type);
      if (url == null || url.isEmpty) return null;

      final savedUrl = type == 'favicon'
          ? await SharedPrefsManager.getMobileFaviconUrl()
          : await SharedPrefsManager.getMobileAppLogoUrl();
      if (savedUrl == url) {
        final cached = await BasicService.getCachedBrandingBytes(type);
        if (cached != null && cached.isNotEmpty) {
          return (url: url, bytes: cached);
        }
      }

      // Otherwise ensure bytes for the latest URL
      final fresh = await BasicService.ensureBrandingBytesForUrl(type, url);
      if (fresh == null || fresh.isEmpty) return null;
      return (url: url, bytes: fresh);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final memBytes = BrandingCache.getBytes(type);
    final memUrl = BrandingCache.getUrl(type);
    if (memBytes != null && memBytes.isNotEmpty && memUrl != null) {
      final path =
          Uri.tryParse(memUrl)?.path.toLowerCase() ?? memUrl.toLowerCase();
      final isSvg = path.endsWith('.svg');
      return isSvg
          ? SvgPicture.memory(
              memBytes,
              height: height,
              width: width,
              fit: BoxFit.contain,
            )
          : Image.memory(
              memBytes,
              height: height,
              width: width,
              fit: BoxFit.contain,
            );
    }

    return FutureBuilder<({String url, Uint8List bytes})?>(
      future: _load(),
      builder: (context, snap) {
        final data = snap.data;
        if (data != null) {
          final path =
              Uri.tryParse(data.url)?.path.toLowerCase() ??
              data.url.toLowerCase();
          final isSvg = path.endsWith('.svg');
          final Widget img = isSvg
              ? SvgPicture.memory(
                  data.bytes,
                  height: height,
                  width: width,
                  fit: BoxFit.contain,
                )
              : Image.memory(
                  data.bytes,
                  height: height,
                  width: width,
                  fit: BoxFit.contain,
                );
          return img;
        }
        if (type == 'favicon') {
          return Image.asset(AssetsPath.errPng, width: 40);
        }
        return Image.asset(AssetsPath.opsPng, width: 80);
      },
    );
  }
}
