import 'dart:convert';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/appointments/models/appointment_details_model.dart';
import 'package:bookapp_customer/features/appointments/models/appointment_model.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:http/http.dart' as http;
import 'package:bookapp_customer/utils/offline_cache.dart';

class AppointmentsService {
  static Future<List<AppointmentModel>> getAppointments() async {
    final uid = AuthAndNetworkService.user?.id;
    final cacheKey = uid != null ? 'appointments_$uid' : 'appointments_guest';
    try {
      final response = await http.get(
        Uri.parse(Urls.appointmentsUrl),
        headers: AuthAndNetworkService.getHeaders(),
      );
      if (response.statusCode == 401) {
        await AuthAndNetworkService.logOut();
        return [];
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        await OfflineCache.putJson(cacheKey, decoded);
        final appointmentsList = decoded['appointments'];
        if (appointmentsList == null || appointmentsList is! List) return [];
        return appointmentsList
            .map<AppointmentModel>((e) => AppointmentModel.fromJson(e))
            .toList();
      }
      // Non-2xx: try cache
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) {
        final appointmentsList = cached['appointments'];
        if (appointmentsList == null || appointmentsList is! List) return [];
        return appointmentsList
            .map<AppointmentModel>((e) => AppointmentModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (_) {
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) {
        final appointmentsList = cached['appointments'];
        if (appointmentsList == null || appointmentsList is! List) return [];
        return appointmentsList
            .map<AppointmentModel>((e) => AppointmentModel.fromJson(e))
            .toList();
      }
      return [];
    }
  }

  static Future<AppointmentDetailsModel> getAppointmentDetails(int id) async {
    final uid = AuthAndNetworkService.user?.id;
    final cacheKey = uid != null ? 'appointment_details_${uid}_$id' : 'appointment_details_guest_$id';
    try {
      final response = await http.get(
        Uri.parse(Urls.appointmentsDetailsUrl(id)),
        headers: AuthAndNetworkService.getHeaders(),
      );
      if (response.statusCode == 401) {
        await AuthAndNetworkService.logOut();
        throw Exception('Unauthorized');
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        await OfflineCache.putJson(cacheKey, decoded);
        return AppointmentDetailsModel.fromJson(decoded);
      }
      // Non-2xx: try cache
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) return AppointmentDetailsModel.fromJson(cached);
      throw Exception('Failed to load appointment: ${response.statusCode}');
    } catch (_) {
      final cached = await OfflineCache.getJson(cacheKey);
      if (cached != null) return AppointmentDetailsModel.fromJson(cached);
      rethrow;
    }
  }
}

