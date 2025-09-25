import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class MonnifyGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor, // NGN kobo
    required String name,
    required String email,
    required String phone,
    String description = 'Order',
  }) async {
    // 1) Initialize on server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/monnify-create.php'),
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
      throw Exception('Monnify create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['redirect_url'] as String?;
    final trx = (data['transactionReference'] ?? '').toString();
    final pref = (data['paymentReference'] ?? '').toString();
    if (url == null || (!trx.isNotEmpty && !pref.isNotEmpty) || !context.mounted) {
      throw Exception('Missing redirect_url/transactionReference');
    }

    // 2) Open hosted checkout
    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': url,
        'finishScheme': 'myapp://monnify-finish',
        'title': 'Monnify',
      },
    ) as bool?;

    if (finished != true) return false;

    // 3) Verify status
    final statusUrl = trx.isNotEmpty
        ? Uri.parse('$pgwBaseUrl/monnify-status.php?transactionReference=$trx')
        : Uri.parse('$pgwBaseUrl/monnify-status.php?paymentReference=$pref');

    final st = await http.get(statusUrl, headers: HttpHeadersHelper.base());
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool success(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? 'UNKNOWN').toString().toUpperCase();
        return s == 'PAID' || s == 'SUCCESS' || s == 'COMPLETED';
      }
      if (decoded is String) {
        final up = decoded.toUpperCase();
        return up.contains('PAID') || up.contains('SUCCESS');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      return success(js);
    } catch (_) {
      return success(st.body);
    }
  }
}
