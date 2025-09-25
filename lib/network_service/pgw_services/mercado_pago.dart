import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class MercadoPagoGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor, // cents (e.g., 25.99 => 2599)
    required String currency, // MXN, BRL, ARS, etc.
    required String name,
    required String email,
    String description = 'Order',
  }) async {
    // 1) Create preference on your server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/mercadopago-create-preference.php'),
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
      throw Exception('Mercado Pago create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final extRef = data['external_reference'] as String?;
    if (url == null || extRef == null || !context.mounted) {
      throw Exception('Missing redirect_url/external_reference');
    }

    // 2) Open hosted checkout
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://mp-finish',
        'title': 'Mercado Pago',
      },
    ) as bool?;

    if (finished != true) return false;

    // 3) Poll status by external_reference
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/mercadopago-status.php?external_reference=$extRef'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool approved(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? 'unknown').toString().toLowerCase();
        return s == 'approved' || s == 'success' || s == 'completed';
      }
      if (decoded is String) {
        final up = decoded.toLowerCase();
        return up.contains('approved') || up.contains('success');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      return approved(js);
    } catch (_) {
      return approved(st.body);
    }
  }
}
