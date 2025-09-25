import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:bookapp_customer/app/urls.dart';

const int kAdminFallbackId = 1;

class CheckoutService {
  // Base URL and endpoints are centralized in Urls

  /// Verify payment amount for a specific gateway keyword (server matches gateway directly).
  static Future<num> verifyPaymentForGateway({
    required String amountRaw,
    required String gatewayKeyword,
    required int vendorId,
    required String bookingDate,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    num normalizeToMajor(num serverValue, num requested) {
      final req = requested.toDouble();
      final val = serverValue.toDouble();
      bool close(double a, double b) => (a - b).abs() < 0.005;
      if (close(val / 100.0, req)) return val / 100.0;
      if (close(val, req)) return val;
      return val;
    }

    final client = http.Client();
    try {
      final parsed = num.tryParse(amountRaw) ?? 0;
      final variants = <String>{};
      if (parsed % 1 == 0) variants.add(parsed.toStringAsFixed(0));
      variants.add(parsed.toStringAsFixed(2));
      variants.add(parsed.toStringAsFixed(1));

      for (final amt in variants) {
        final uri = Uri.parse(Urls.verifyPaymentUrl(
          amount: amt,
          gateway: gatewayKeyword,
          vendorId: vendorId,
          bookingDate: bookingDate,
        ));
        final headers = {
          ...HttpHeadersHelper.base(),
          'Content-Type': 'text/plain',
          'Accept': 'text/plain,application/json',
        };
        final res = await client.post(uri, headers: headers, body: amt).timeout(timeout);
        if (res.statusCode == 200) {
          final body = res.body.trim();
          final asNum = num.tryParse(body);
          if (asNum != null && asNum > 0) {
            final reqNum = num.tryParse(amt) ?? 0;
            return normalizeToMajor(asNum, reqNum);
          }
          try {
            final js = jsonDecode(body);
            final maybe = js['amount'];
            final asNum2 = (maybe is num) ? maybe : num.tryParse('$maybe');
            if (asNum2 != null && asNum2 > 0) {
              final reqNum = num.tryParse(amt) ?? 0;
              return normalizeToMajor(asNum2, reqNum);
            }
          } catch (_) {
            /* noop */
          }
        }
      }
      throw Exception('Payment verification failed for gateway=$gatewayKeyword amount $amountRaw.');
    } finally {
      client.close();
    }
  }

  static Future<num> verifyPaymentSmart({
    required String amountRaw,
    required int vendorId,
    required String bookingDate,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final client = http.Client();
    try {
      final gateways = <String>[
        'payPal',
        'paypal',
        'PayPal',
        'stripe',
        'Stripe',
        'flutterwave',
        'Flutterwave',
      ];
      final vendors = <int>{vendorId, 7, 0, kAdminFallbackId}.toList();

      final parsed = num.tryParse(amountRaw) ?? 0;
      final variants = <String>{};
      if (parsed % 1 == 0) variants.add(parsed.toStringAsFixed(0));
      variants.add(parsed.toStringAsFixed(2));
      variants.add(parsed.toStringAsFixed(1));

      // Shuffle a little to avoid always hitting the exact same combo first (optional)
      gateways.shuffle(Random());
      vendors.shuffle(Random());

      num normalizeToMajor(num serverValue, num requested) {
        final req = requested.toDouble();
        final val = serverValue.toDouble();
        bool close(double a, double b) => (a - b).abs() < 0.005;
        // If server returned paise/cents (x100), convert back to major
        if (close(val / 100.0, req)) return val / 100.0;
        // If it already matches requested major amount, keep as-is
        if (close(val, req)) return val;
        return val; // Unknown scaling, return raw (server might include fees)
      }

      for (final gw in gateways) {
        for (final vid in vendors) {
          for (final amt in variants) {
            final uri = Uri.parse(Urls.verifyPaymentUrl(
              amount: amt,
              gateway: gw,
              vendorId: vid,
              bookingDate: bookingDate,
            ));

            final base = HttpHeadersHelper.base();
            final headers = {
              ...base,
              'Content-Type': 'text/plain',
              'Accept': 'text/plain,application/json',
            };
            final res = await client
                .post(uri, headers: headers, body: amt)
                .timeout(timeout);

            if (res.statusCode == 200) {
              final body = res.body.trim();
              final asNum = num.tryParse(body);
              if (asNum != null && asNum > 0) {
                final reqNum = num.tryParse(amt) ?? 0;
                return normalizeToMajor(asNum, reqNum);
              }
              // If JSON is returned, try parse and pull 'amount'
              try {
                final js = jsonDecode(body);
                final maybe = js['amount'];
                final asNum2 = (maybe is num) ? maybe : num.tryParse('$maybe');
                if (asNum2 != null && asNum2 > 0) {
                  final reqNum = num.tryParse(amt) ?? 0;
                  return normalizeToMajor(asNum2, reqNum);
                }
              } catch (_) {
                /* noop */
              }
            }
          }
        }
      }

      throw Exception('Payment verification failed for amount $amountRaw.');
    } finally {
      client.close();
    }
  }

  // ------------------ Checkout (backend finalize) ------------------

  /// Sends final booking/payment to your backend.
  /// If [bearerToken] is provided, adds `Authorization: Bearer <token>`.
  /// You can also merge custom [headers] and control [timeout].
  static Future<Map<String, dynamic>> paymentProcess(
    Map<String, String> fields, {
    String? bearerToken,
    Map<String, String>? headers,
    // Optional single or multiple file attachments: field name -> file path
    Map<String, String>? filePaths,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse(Urls.paymentProcessUrl));
    req.fields.addAll(fields);

    // Default headers
    final base = HttpHeadersHelper.base();
    req.headers.addAll(base);
    req.headers['Accept'] = 'application/json';
    if (bearerToken != null && bearerToken.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $bearerToken';
    }
    if (headers != null) {
      req.headers.addAll(headers);
    }

    // Attach files if provided (e.g., offline payment receipt)
    if (filePaths != null && filePaths.isNotEmpty) {
      for (final entry in filePaths.entries) {
        final field = entry.key;
        final path = entry.value;
        if (path.trim().isEmpty) continue;
        try {
          final file = await http.MultipartFile.fromPath(field, path);
          req.files.add(file);
        } catch (_) {
          // Ignore bad file path; server will still get the fields
        }
      }
    }

    final streamed = await req.send().timeout(timeout);
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      try {
        final js = jsonDecode(body);
        return (js is Map<String, dynamic>) ? js : {'data': js};
      } catch (_) {
        return {'raw': body};
      }
    }

    // Try to extract server error details if JSON
    try {
      final err = jsonDecode(body);
      throw Exception('payment-process ${streamed.statusCode}: $err');
    } catch (_) {
      throw Exception('payment-process ${streamed.statusCode}: $body');
    }
  }
}
