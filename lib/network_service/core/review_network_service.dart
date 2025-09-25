import 'dart:convert';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ReviewSubmitResult {
  final bool success;
  final String message;

  const ReviewSubmitResult({required this.success, required this.message});
}

class ReviewNetworkService {
  static Future<ReviewSubmitResult> submitReview({
    required int serviceId,
    required int rating,
    required String comment,
  }) async {
    final uri = Uri.parse(Urls.storeReviewUrl(serviceId));
    final headers = <String, String>{
      ...AuthAndNetworkService.getHeaders(),
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'rating': rating, 'comment': comment.trim()});

    try {
      final res = await http.post(uri, headers: headers, body: body);
      debugPrint('Review POST status: ${res.statusCode}');
      debugPrint('Review POST body: ${res.body}');

      final contentType = res.headers['content-type'] ?? '';
      final isJson = contentType.contains('application/json');

      bool success = false;
      String message = 'Something went wrong.';

      if (isJson) {
        final decoded = jsonDecode(res.body);

        if (decoded is Map) {
          if (decoded['message'] != null) {
            message = decoded['message'].toString();
          }
          if (decoded['success'] is bool) {
            success = decoded['success'] as bool;
          }
        }

        if (res.statusCode == 422 && decoded['errors'] is Map) {
          final errors = decoded['errors'] as Map;
          final firstKey = errors.keys.cast<String?>().firstWhere(
            (k) => k != null && (errors[k] as List?)?.isNotEmpty == true,
            orElse: () => null,
          );
          if (firstKey != null) {
            message = (errors[firstKey] as List).first.toString();
          } else {
            message = 'Validation failed.';
          }
          success = false;
        }

        if (res.statusCode == 200 && decoded['success'] == false) {
          success = false;
          message = decoded['message']?.toString() ?? message;
        }
      } else {
        success = res.statusCode >= 200 && res.statusCode < 300;
        message = res.body.isNotEmpty ? res.body : message;
      }

      if (res.statusCode == 401) {
        return const ReviewSubmitResult(
          success: false,
          message: 'Login to write a review',
        );
      }
      if (res.statusCode == 403 && message.isEmpty) {
        message = 'You have not bought this service yet!';
      }

      return ReviewSubmitResult(success: success, message: message);
    } catch (e) {
      debugPrint('Review POST error: $e');
      return ReviewSubmitResult(success: false, message: 'Network error: $e');
    }
  }
}
