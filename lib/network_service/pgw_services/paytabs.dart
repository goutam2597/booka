import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class PayTabsGateway {
  static Future<bool> startHostedPayment({
    required BuildContext context,
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    required String phone,
    String description = 'Order',
  }) async {
    // 1) Create session on your server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/paytabs-create-session.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency.toUpperCase(),
        'name': name,
        'email': email,
        'phone': phone,
        'description': description,
      }),
    );
    if (res.statusCode >= 300) {
      throw Exception('PayTabs create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final ref = (data['tranRef'] ?? data['transactionReference'] ?? '').toString();
    if (url == null || ref.isEmpty || !context.mounted) {
      throw Exception('Missing redirect_url/tranRef');
    }

    // 2) Open hosted page
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://paytabs-finish',
        'title': 'PayTabs',
      },
    ) as bool?;

    if (finished != true) return false;

    // 3) Verify status on server
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/paytabs-status.php?tranRef=$ref'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool ok(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? '').toString().toUpperCase();
        return s == 'A' || s == 'APPROVED' || s == 'CAPTURED' || s == 'SUCCESS';
      }
      if (decoded is String) {
        final up = decoded.toUpperCase();
        return up.contains('APPROVED') || up.contains('SUCCESS');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      return ok(js);
    } catch (_) {
      return ok(st.body);
    }
  }
}
