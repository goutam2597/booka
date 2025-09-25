import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';
import '../../app/app_constants.dart';

class AuthorizeNetGateway {
  /// Returns true on success (success deeplink), false on user cancel (cancel deeplink).
  static Future<bool> startCheckout({
    required BuildContext context,
    required String amountString,
    required String currency,
  }) async {
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/anet-get-token.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amountString, 'currency': currency}),
    );
    if (res.statusCode >= 300) {
      throw Exception('anet-get-token failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    final checkoutUrl = data['checkout_url'] as String?;

    if (token == null && checkoutUrl == null && !context.mounted) {
      throw Exception('No token/checkout_url from server');
    }

    final finished = await Get.toNamed(
      AppRoutes.authorizeNetWebView,
      arguments: {
        'token': token,
        'checkoutUrl': checkoutUrl,
        'successScheme': 'myapp://anet-success',
        'cancelScheme': 'myapp://anet-cancel',
        'title': 'Authorize.Net',
      },
    ) as bool?;

    return finished == true;
  }
}
