import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class MyFatoorahGateway {
	static Future<bool> startCheckout({
		required BuildContext context,
		required int amountMinor,
		required String currency,
		required String name,
		required String email,
		String? phone,
		String countryDialCode = "+965",
		String description = 'Order',
	}) async {
		// 1) Create payment session on server
		final res = await http.post(
			Uri.parse('$pgwBaseUrl/myfatoorah-create-payment.php'),
			headers: {
				...HttpHeadersHelper.base(),
				'Content-Type': 'application/json',
			},
			body: jsonEncode({
				'amount_minor': amountMinor,
				'currency': currency.toUpperCase(),
				'name': name,
				'email': email,
				'phone': phone ?? '',
				'country_dial_code': countryDialCode,
				'description': description,
			}),
		);

		if (res.statusCode >= 300) {
			throw Exception('MyFatoorah create failed: ${res.body}');
		}

		final data = jsonDecode(res.body) as Map<String, dynamic>;
		final url = data['redirect_url'] as String?;
		final invoiceId = data['invoice_id']?.toString();
		if (url == null || invoiceId == null || !context.mounted) {
			throw Exception('Missing redirect_url/invoice_id');
		}

		// 2) Open hosted page
		final finished = await Get.toNamed(
			AppRoutes.checkoutWebView,
			arguments: {
				'url': url,
				'finishScheme': 'myapp://myfatoorah-finish',
				'title': 'MyFatoorah',
			},
		) as bool?;

		if (finished != true) return false;

		// 3) Verify invoice status (server is the source of truth)
		Future<http.Response> statusOnce() {
			return http.get(
				Uri.parse('$pgwBaseUrl/myfatoorah-status.php?invoice_id=$invoiceId'),
				headers: HttpHeadersHelper.base(),
			);
		}

		bool isTruthy(dynamic v) {
			if (v is bool) return v;
			if (v is num) return v == 1 || v > 0;
			if (v is String) {
				final s = v.toLowerCase();
				return s == 'true' || s == '1' || s == 'ok' || s == 'yes' || s == 'paid' || s == 'success' || s == 'completed' || s == 'captured' || s == 'approved';
			}
			return false;
		}

		bool looksPaidString(String s) {
			final up = s.toLowerCase();
			return up.contains('paid') || up.contains('success') || up.contains('completed') || up.contains('captured') || up.contains('approved');
		}

		bool paidDeep(dynamic decoded) {
			if (decoded is Map) {
				for (final entry in decoded.entries) {
					final key = entry.key.toString().toLowerCase();
					final val = entry.value;
					// Common boolean flags
					if (key == 'success' || key == 'is_success' || key == 'issuccess' || key == 'ok' || key == 'paid') {
						if (isTruthy(val)) return true;
					}
					// Common status-bearing keys (case-insensitive)
					if (key.contains('status')) {
						if (val is String && looksPaidString(val)) return true;
					}
					if (key == 'invoicestatus' || key == 'paymentstatus' || key == 'status') {
						if (val is String && looksPaidString(val)) return true;
					}
					// Recurse into nested structures
					if (paidDeep(val)) return true;
				}
				return false;
			}
			if (decoded is List) {
				for (final item in decoded) {
					if (paidDeep(item)) return true;
				}
				return false;
			}
			if (decoded is String) {
				return looksPaidString(decoded);
			}
			return isTruthy(decoded);
		}


		bool looksTerminalFailure(dynamic decoded) {
			final s = decoded.toString().toLowerCase();
			return s.contains('failed') || s.contains('canceled') || s.contains('cancelled') || s.contains('expired');
		}

		// Poll a few times as gateways may be eventually consistent immediately after return
		const maxAttempts = 6; // ~6-9 seconds depending on delay
		for (var attempt = 1; attempt <= maxAttempts; attempt++) {
			final st = await statusOnce();
			if (st.statusCode >= 300) {
				// propagate details for visibility
				throw Exception('Status failed: ${st.body}');
			}
			try {
				final js = jsonDecode(st.body);
				if (paidDeep(js)) return true;
				if (looksTerminalFailure(js)) return false;
			} catch (_) {
				final body = st.body;
				if (paidDeep(body)) return true;
				if (looksTerminalFailure(body)) return false;
			}
			// not yet finalized -> short backoff then retry
			await Future.delayed(Duration(milliseconds: attempt < 3 ? 1200 : 1800));
		}
		// Give up as not conclusively paid
		return false;
	}
}

