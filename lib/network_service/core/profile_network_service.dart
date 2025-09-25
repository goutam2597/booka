import 'dart:convert';
import 'dart:io';

import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/utils/offline_cache.dart';

class ProfileNetworkService {
  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String name,
    required String email,
    required String phone,
    required String state,
    required String zipCode,
    required String country,
    required String address,
    File? image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Urls.updateProfileUrl),
      );
      request.headers.addAll(AuthAndNetworkService.getHeaders());

      request.fields['username'] = username;
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['state'] = state;
      request.fields['zip_code'] = zipCode;
      request.fields['country'] = country;
      request.fields['address'] = address;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 401) {
        await AuthAndNetworkService.logOut();
        return {'success': false, 'message': 'Unauthorized'};
      }
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final uid = AuthAndNetworkService.user?.id;
    final cacheKey = uid != null ? 'profile_$uid' : 'profile_guest';
    try {
      final response = await http.get(
        Uri.parse(Urls.editProfileUrl),
        headers: AuthAndNetworkService.getHeaders(),
      );
      if (response.statusCode == 401) {
        await AuthAndNetworkService.logOut();
        return {'success': false, 'message': 'Unauthorized'};
      }
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        await OfflineCache.putJson(cacheKey, decoded);
        return {
          'success': decoded['status'] == 'success',
          'data': decoded['data'] ?? {},
        };
      } else {
        // Fallback to cache on non-200
        final cached = await OfflineCache.getJson(cacheKey);
        if (cached != null) {
          return {
            'success': cached['status'] == 'success' || true,
            'data': cached['data'] ?? {},
          };
        }
        return {
          'success': false,
          'message': 'Server Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error: try cache
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) {
        return {
          'success': cached['status'] == 'success' || true,
          'data': cached['data'] ?? {},
        };
      }
      return {'success': false, 'message': e.toString()};
    }
  }
}
