import 'dart:convert';

import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:bookapp_customer/utils/offline_cache.dart';

class VendorNetworkService {


  static Future<List<VendorModel>> getVendorList() async {
    try {
      final response = await http.get(
        Uri.parse(Urls.vendorsUrl),
        headers: HttpHeadersHelper.base(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        // Cache full root for offline reuse
        await OfflineCache.putJson('vendors_root', decoded);
        final List vendors = (decoded['data']?['vendors'] as List?) ?? const [];
        return vendors.map((e) => VendorModel.fromJson(e)).toList();
      }
      // Non-200: try cache
      final cached = await OfflineCache.getJson('vendors_root');
      if (cached != null) {
        final List vendors = (cached['data']?['vendors'] as List?) ?? const [];
        return vendors.map((e) => VendorModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load vendor list');
    } catch (_) {
      final cached = await OfflineCache.getJson('vendors_root');
      if (cached != null) {
        final List vendors = (cached['data']?['vendors'] as List?) ?? const [];
        return vendors.map((e) => VendorModel.fromJson(e)).toList();
      }
      rethrow;
    }
  }

  static Future<VendorDetailsModel> getVendorDetails(
    String vendorUsername,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(Urls.vendorDetailsUrl(vendorUsername)),
        headers: HttpHeadersHelper.base(),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>;
        // Cache per-username for offline detail view
        await OfflineCache.putJson('vendor_details_$vendorUsername', data);
        return VendorDetailsModel.fromJson(data);
      }
      // Fallback to cache
      final cached = await OfflineCache.getJson('vendor_details_$vendorUsername');
      if (cached != null) return VendorDetailsModel.fromJson(cached);
      throw Exception('Failed to load vendor details');
    } catch (_) {
      final cached = await OfflineCache.getJson('vendor_details_$vendorUsername');
      if (cached != null) return VendorDetailsModel.fromJson(cached);
      rethrow;
    }
  }

  /// Convenience: fetch vendor details by vendor id
  static Future<VendorDetailsModel> getVendorDetailsById(int vendorId) async {
    // First, find the username for the id from the vendors list
    try {
      final all = await getVendorList();
      final match = all.firstWhere(
        (v) => v.id == vendorId,
        orElse: () => VendorModel.empty(),
      );
      final uname = match.username;
      if (uname.isNotEmpty && uname.toLowerCase() != 'admin') {
        return getVendorDetails(uname);
      }
      // If admin or not found, some backends expose details at 'admin'
      return getVendorDetails(uname.isNotEmpty ? uname : 'admin');
    } catch (_) {
      // Last resort: try known slug 'admin'
      return getVendorDetails('admin');
    }
  }
}
