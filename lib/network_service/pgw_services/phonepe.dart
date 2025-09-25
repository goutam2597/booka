import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/network_service/http_headers.dart';

import '../../app/routes/app_routes.dart';
import '../../app/app_constants.dart';

class PhonePeGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor,
    required String merchantUserId,
    required String name,
    required String email,
    String mobile = '',
    String description = 'Order',
    required String currency,
  }) async {
    // 1) Create payment session on your server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/phonepe-create-payment.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'merchant_user_id': merchantUserId,
        'mobile': mobile,
        'name': name,
        'email': email,
        'description': description,
        'currency': currency.toUpperCase(),
      }),
    );

    if (res.statusCode >= 300) {
      throw Exception('PhonePe create failed: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final mtx = data['merchant_txn_id'] as String?;
    if (url == null || mtx == null) {
      throw Exception('Missing redirect_url / merchant_txn_id');
    }

    // 2) Open hosted checkout in our shared webview
    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': url,
                'finishScheme': 'myapp://phonepe-return',
                'title': 'PhonePe',
              },
            )
            as bool?;

    if (finished != true) return false; // user cancelled

    // 3) Verify status on server
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/phonepe-status.php?merchant_txn_id=$mtx'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    // Be tolerant: backend might return plain text or different JSON shapes
    bool isSuccessMap(Map<String, dynamic> m) {
      String up(Object? v) => (v ?? '').toString().toUpperCase();
      if (m['success'] == true) return true;
      final s = up(m['status']);
      if (s.contains('SUCCESS') ||
          s == 'COMPLETED' ||
          s == 'PAID' ||
          s == 'CAPTURED' ||
          s == 'SETTLEMENT' ||
          s == 'SETTLED') {
        return true;
      }
      final rs = up(m['result']);
      if (rs.contains('SUCCESS')) return true;
      final txn = up(
        m['transaction_status'] ??
            m['transactionStatus'] ??
            m['payment_status'],
      );
      if (txn.contains('SUCCESS') ||
          txn == 'COMPLETED' ||
          txn == 'CAPTURED' ||
          txn == 'SETTLEMENT' ||
          txn == 'SETTLED') {
        return true;
      }
      final data = m['data'];
      if (data is Map<String, dynamic>) return isSuccessMap(data);
      return false;
    }

    try {
      final decoded = jsonDecode(st.body);
      if (decoded is Map<String, dynamic>) {
        return isSuccessMap(decoded);
      }
      if (decoded is String) {
        final up = decoded.toUpperCase();
        return up.contains('SUCCESS') ||
            up.contains('COMPLETED') ||
            up.contains('PAID');
      }
    } catch (_) {
      // Not JSON; fall back to text search
      final up = st.body.toUpperCase();
      if (up.contains('SUCCESS') ||
          up.contains('COMPLETED') ||
          up.contains('PAID')) {
        return true;
      }
    }
    return false;
  }
}
