import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class ToyyibpayGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor, // MYR in sen
    required String name,
    required String email,
    required String phone,
    String description = 'Order',
  }) async {
    // 1) Create bill on your server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/toyyibpay-create-bill.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'name': name,
        'email': email,
        'phone': phone,
        'description': description,
      }),
    );

    if (res.statusCode >= 300) {
      throw Exception('Toyyibpay create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final billCode = data['billCode'] as String?;
    if (url == null || billCode == null || !context.mounted) {
      throw Exception('Missing redirect_url/billCode');
    }

    // 2) Open hosted checkout
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://toyyibpay-finish',
        'title': 'Toyyibpay',
      },
    ) as bool?;

    if (finished != true) return false;

    // 3) Verify status
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/toyyibpay-status.php?billCode=$billCode'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool isPaid(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        // Toyyibpay: '1' = paid, '2' = pending, '3' = failed
        final s = (decoded['status'] ?? '').toString();
        return s == '1' || s.toLowerCase() == 'paid';
      }
      if (decoded is String) {
        final up = decoded.toLowerCase();
        return up.contains('1') || up.contains('paid');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      return isPaid(js);
    } catch (_) {
      return isPaid(st.body);
    }
  }
}
