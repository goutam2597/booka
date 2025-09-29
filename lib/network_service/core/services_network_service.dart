import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_data_model.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:bookapp_customer/utils/offline_cache.dart';

class ServicesNetworkService {
  /// Existing typed method
  Future<ServicesDataModel> getServices() async {
    try {
      final response = await http.get(
        Uri.parse(Urls.servicesUrl),
        headers: HttpHeadersHelper.base(),
      );

      if (response.statusCode == 200) {
        return ServicesDataModel.fromJson(jsonDecode(response.body)['data']);
      }
      // Non-200: fallback to cached root if available
      final cached = await OfflineCache.getJson('services_root');
      if (cached != null) {
        final data = (cached['data'] as Map<String, dynamic>?);
        if (data != null) return ServicesDataModel.fromJson(data);
      }
      throw Exception('Failed to load services');
    } catch (_) {
      final cached = await OfflineCache.getJson('services_root');
      if (cached != null) {
        final data = (cached['data'] as Map<String, dynamic>?);
        if (data != null) return ServicesDataModel.fromJson(data);
      }
      rethrow;
    }
  }

  /// Returns the raw JSON root from API
  /// Useful when you need categories + featuredServices + services.
  Future<Map<String, dynamic>> getServicesRoot() async {
    try {
      final response = await http.get(
        Uri.parse(Urls.servicesUrl),
        headers: HttpHeadersHelper.base(),
      );

      if (response.statusCode == 200) {
        final js = jsonDecode(response.body) as Map<String, dynamic>;
        // Cache the entire root for offline
        await OfflineCache.putJson('services_root', js);
        return js;
      } else {
        final cached = await OfflineCache.getJson('services_root');
        if (cached != null) return cached;
        throw Exception('Failed to load services root');
      }
    } catch (_) {
      final cached = await OfflineCache.getJson('services_root');
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Fetch details for a single service by slug & id
  Future<ServiceDetailsModel> getServiceDetails(String slug, int id) async {
    try {
      final response = await http.get(
        Uri.parse(Urls.servicesDetailsUrl(slug, id)),
        headers: HttpHeadersHelper.base(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = (decoded['data'] as Map<String, dynamic>);
        await OfflineCache.putJson('service_details_$id', data);
        return ServiceDetailsModel.fromJson(data);
      } else {
        final cached = await OfflineCache.getJson('service_details_$id');
        if (cached != null) return ServiceDetailsModel.fromJson(cached);
        throw Exception('Failed to load service details for id: $id');
      }
    } catch (_) {
      final cached = await OfflineCache.getJson('service_details_$id');
      if (cached != null) return ServiceDetailsModel.fromJson(cached);
      rethrow;
    }
  }
}
