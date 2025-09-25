import 'dart:convert';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Simple result wrapper so the UI knows success vs failure and a message.
class ApiResult {
  final bool success;
  final String message;
  const ApiResult({required this.success, required this.message});
}

class EmailNetworkService {
  /// Sends a service inquiry message.
  ///
  /// Returns [ApiResult] with `success` and a human-friendly `message`.
  static Future<ApiResult> sendInquiry({
    required String vendorId,
    required String serviceId,
    required String firstName,
    required String lastName,
    required String email,
    required String message,
  }) async {
    try {
      final uri = Uri.parse(Urls.serviceInquiryUrl);
      final headers = {
        ...AuthAndNetworkService.getHeaders(),
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      final body = {
        'vendor_id': vendorId,
        'service_id': serviceId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'message': message,
      };

      final resp = await http.post(uri, headers: headers, body: body);

      debugPrint('Inquiry status: ${resp.statusCode}');
      debugPrint('Inquiry body: ${resp.body}');

      var ok = resp.statusCode >= 200 && resp.statusCode < 300;
      var msg = 'Something went wrong';

      try {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        msg =
            (decoded['message'] ?? decoded['status'] ?? decoded['success'])
                ?.toString() ??
            msg;
        final statusStr = decoded['status']?.toString().toLowerCase();
        ok =
            ok &&
            (statusStr == 'success' ||
                decoded['success'] == true ||
                msg.toLowerCase().contains('success'));
      } catch (_) {
        // Non-JSON; keep ok based on HTTP and default msg.
      }

      return ApiResult(success: ok, message: msg);
    } catch (e) {
      debugPrint('Inquiry error: $e');
      return const ApiResult(success: false, message: 'Failed to send message');
    }
  }

  static Future<ApiResult> vendorContact({
    required String name,
    required String email,
    required String subject,
    required String message,
    required String vendorEmail,
  }) async {
    try {
      final uri = Uri.parse(Urls.vendorInquiryUrl);
      final headers = {
        ...AuthAndNetworkService.getHeaders(),
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      final body = {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'vendor_email': vendorEmail,
      };
      final response = await http.post(uri, headers: headers, body: body);

      debugPrint('Inquiry status: ${response.statusCode}');
      debugPrint('Inquiry body: ${response.body}');

      var ok = response.statusCode >= 200 && response.statusCode < 300;
      var msg = 'Something went wrong';

      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        msg =
            (decoded['message'] ?? decoded['status'] ?? decoded['success'])
                ?.toString() ??
            msg;
        final statusStr = decoded['status']?.toString().toLowerCase();
        ok =
            ok &&
            (statusStr == 'success' ||
                decoded['success'] == true ||
                msg.toLowerCase().contains('success'));
      } catch (_) {}
      return ApiResult(success: ok, message: msg);
    } catch (e) {
      debugPrint('Inquiry error: $e');
      return const ApiResult(success: false, message: 'Failed to send message');
    }
  }
}
