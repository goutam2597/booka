import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class NowPaymentsGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
  }) async {
    // 1) Create invoice via backend
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/nowpayments-create-invoice.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency,
        'name': name,
        'email': email,
      }),
    );
    if (res.statusCode >= 300) {
      throw Exception('NOWPayments create failed: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final invoiceId = (data['invoice_id'] ?? '').toString();
    if (url == null || invoiceId.isEmpty || !context.mounted) {
      throw Exception('Missing redirect_url/invoice_id');
    }

    // 2) Open hosted invoice
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://nowpayments-finish',
        'title': 'NOWPayments',
      },
    ) as bool?;

    if (finished != true) return false;

    // 3) Check status
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/nowpayments-invoice-status.php?invoice_id=$invoiceId'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool isDone(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? 'Unknown').toString().toLowerCase();
        return s == 'finished' || s == 'confirmed' || s == 'completed';
      }
      if (decoded is String) {
        final up = decoded.toLowerCase();
        return up.contains('finished') || up.contains('confirmed');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      return isDone(js);
    } catch (_) {
      return isDone(st.body);
    }
  }
}
