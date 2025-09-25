import 'dart:convert';

import 'package:bookapp_customer/app/urls.dart';
import 'package:http/http.dart' as http;

class ForgetPassNetworkService {
  Future<String> sendOtp({required String email}) async {
    final request = http.MultipartRequest('POST', Uri.parse(Urls.forgetPassUrl))
      ..fields['email'] = email;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = _tryJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return (body['message'] as String?) ?? 'OTP has been sent to your email';
    } else {
      throw ApiException((body['message'] as String?) ?? 'Failed to send Otp');
    }
  }

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(Urls.resetPassUrl))
      ..fields['email'] = email
      ..fields['code'] = code
      ..fields['new_password'] = newPassword
      ..fields['new_password_confirmation'] = confirmPassword;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = _tryJson(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return (body['message'] as String?) ??
          'Password has been reset successfully';
    } else {
      throw ApiException(
        (body['message'] as String?) ?? 'Failed to reset password',
      );
    }
  }

  Map<String, dynamic> _tryJson(String s) {
    try {
      return json.decode(s) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
