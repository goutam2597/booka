import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/app_constants.dart';

class GooglePayStripeGateway {
  static Future<bool> onPaymentResult({
    required BuildContext context,
    required dynamic result,
    required int amountMinor,
    required String currency,
  }) async {
    final map = (result is Map<String, dynamic>)
        ? result
        : jsonDecode(jsonEncode(result)) as Map<String, dynamic>;

    final gpayTokenRaw =
        map['paymentMethodData']?['tokenizationData']?['token'];
    if (gpayTokenRaw == null) {
      throw Exception('No token from Google Pay.');
    }

    String? stripeTok;
    dynamic tokenPayload = gpayTokenRaw;

    try {
      if (tokenPayload is String) {
        final parsed = jsonDecode(tokenPayload);
        tokenPayload = parsed;
        if (parsed is Map &&
            parsed['id'] is String &&
            (parsed['id'] as String).startsWith('tok_')) {
          stripeTok = parsed['id'];
        } else if (gpayTokenRaw is String && gpayTokenRaw.startsWith('tok_')) {
          stripeTok = gpayTokenRaw;
        }
      } else if (tokenPayload is Map) {
        if (tokenPayload['id'] is String &&
            (tokenPayload['id'] as String).startsWith('tok_')) {
          stripeTok = tokenPayload['id'];
        }
      }
    } catch (_) {

    }

    final createPiRes = await http.post(
      Uri.parse('$pgwBaseUrl/create-payment-intent.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amountMinor, 'currency': currency}),
    );
    if (createPiRes.statusCode >= 300) {
      throw Exception('Create PI failed: ${createPiRes.body}');
    }
    final pi = jsonDecode(createPiRes.body) as Map<String, dynamic>;
    final piId = pi['id'] as String?;
    if (piId == null) throw Exception('No PaymentIntent id');

    final confirmRes = await http.post(
      Uri.parse('$pgwBaseUrl/confirm-googlepay.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'payment_intent_id': piId,
        if (stripeTok != null) 'token': stripeTok,
        if (stripeTok == null) 'googlepay_token': tokenPayload,
      }),
    );
    if (confirmRes.statusCode >= 300) {
      throw Exception('Confirm failed: ${confirmRes.body}');
    }
    final confirmed = jsonDecode(confirmRes.body) as Map<String, dynamic>;
    final status =
        (confirmed['status'] ?? confirmed['payment_intent_status'] ?? '')
            .toString()
            .toLowerCase();

    return status == 'succeeded' || status == 'requires_capture';
  }
}
