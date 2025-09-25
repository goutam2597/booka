import 'dart:convert';
import 'package:bookapp_customer/app/urls.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/date_time_response_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:http/http.dart' as http;

class BookingNetworkService {
  const BookingNetworkService._();

  static Future<List<StaffModel>> getStaffByService(int service) async {
    final uri = Uri.parse(Urls.getStaffContentUrl(service));
    final response = await http.get(
      uri,
      headers: AuthAndNetworkService.getHeaders(),
    );

    if (response.statusCode != 200) return [];
    final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
    final data = decoded?['data'];
    if (data is! Map<String, dynamic>) return [];

    final staffs = data['staffs'];
    if (staffs is! List) return [];
    return staffs
        .whereType<Map<String, dynamic>>()
        .map(StaffModel.fromJson)
        .toList();
  }

  static Future<List<AvailableTimeResponseModel>> getStaffAvailableTimes({
    required String dayName,
    required int staffId,
    required String bookingDate,
    required int vendorId,
    required int serviceId,
  }) async {
    final uri = Uri.parse(
      Urls.staffHoursUrl(dayName, staffId, bookingDate, vendorId, serviceId),
    );

    final response = await http.get(
      uri,
      headers: AuthAndNetworkService.getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load staff hours (HTTP ${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return [];

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) return [];

    // If API omits or sends invalid maxPerson, leave it as null.
    final maxPersonStr = data['maxPerson']?.toString();
    final int? maxPerson = int.tryParse(maxPersonStr ?? '');

    final staffTime = data['staff_time'];
    final globalTime = data['global_time'];

    // Respect staff.is_day flag when present:
    // - is_day == 1 => show only staff_time
    // - is_day == 0 => show only global_time
    bool? isDay; // null means unknown, fallback to existing behavior
    final staffObj = data['staff'];
    if (staffObj is Map<String, dynamic>) {
      final val = staffObj['is_day']?.toString().trim();
      if (val != null) {
        if (val == '1' || val.toLowerCase() == 'true') {
          isDay = true;
        } else if (val == '0' || val.toLowerCase() == 'false') {
          isDay = false;
        }
      }
    }

    late final List<dynamic> rawList;
    if (isDay == true) {
      rawList = (staffTime is List) ? staffTime : const [];
    } else if (isDay == false) {
      rawList = (globalTime is List) ? globalTime : const [];
    } else {
      // Fallback: prefer staff time when available
      rawList = (staffTime is List && staffTime.isNotEmpty)
          ? staffTime
          : (globalTime is List ? globalTime : const []);
    }

    if (rawList.isEmpty) return [];

    return AvailableTimeResponseModel.fromGlobalTimeList(
      rawList,
      maxPerson: maxPerson, // may be null
    );
  }

  /// Fetch global date/time configuration for a vendor + service, including
  /// globalWeekend (list of weekend day names) and optional holidays.
  static Future<DateTimeResponseModel?> getDateTimeConfig({
    required int vendorId,
    required int serviceId,
  }) async {
    final uri = Uri.parse(Urls.dateTimeUrl(vendorId, serviceId));
    final response = await http.get(
      uri,
      headers: AuthAndNetworkService.getHeaders(),
    );
    if (response.statusCode != 200) {
      return null;
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return DateTimeResponseModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }}


