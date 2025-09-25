import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class XenditGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    String description = 'Order',
  }) async {
    // 1) Create invoice on server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/xendit-create-payment.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency.toUpperCase(),
        'name': name,
        'email': email,
        'description': description,
      }),
    );

    if (res.statusCode >= 300) {
      throw Exception('Xendit create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final invoiceId = data['invoice_id'] as String?;
    if (url == null || invoiceId == null || !context.mounted) {
      throw Exception('Missing redirect_url/invoice_id');
    }

    // 2) Open hosted page
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://xendit-finish',
        'title': 'Xendit',
      },
    ) as bool?;

    if (finished != true) return false;

    // 3) Verify status by invoice id
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/xendit-status.php?invoice_id=$invoiceId'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool isPaid(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? '').toString().toLowerCase();
        return s == 'paid' || s == 'settled' || s == 'completed' || s == 'success';
      }
      if (decoded is String) {
        final up = decoded.toLowerCase();
        return up.contains('paid') || up.contains('success');
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
