import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';


const int kAdminFallbackStaffId = 1;

class BookingPayload {
  static String _normalizeTime(String t) {
    final v = t.trim();
    if (v.isEmpty) return '';
    final hhmmss = RegExp(r'^\d{2}:\d{2}:\d{2}$');
    if (hhmmss.hasMatch(v)) return v;
    final hhmm = RegExp(r'^\d{2}:\d{2}$');
    if (hhmm.hasMatch(v)) return '$v:00';
    final ampm = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])\s*$');
    final m = ampm.firstMatch(v);
    if (m != null) {
      var h = int.tryParse(m.group(1)!) ?? 0;
      final min = m.group(2)!;
      final ap = m.group(3)!.toUpperCase();
      if (ap == 'PM' && h < 12) h += 12;
      if (ap == 'AM' && h == 12) h = 0;
      final hh = h.toString().padLeft(2, '0');
      return '$hh:$min:00';
    }
    return v;
  }

  static Map<String, String> build({
    required double amountMajor,
    required ServicesModel service,
    required StaffModel staff,
    required DateTime bookingDate,
    required AvailableTimeResponseModel slot,
    required Map<String, String> mergedBilling,
    required String persons,
    required String userId,
    required String method,
    required String gatewayType,
  }) {
    final start = _normalizeTime((slot.startTime).toString());
    final end = _normalizeTime((slot.endTime).toString());
    final int effectiveStaffId = (staff.isFallback == true || staff.id <= 0)
        ? kAdminFallbackStaffId
        : staff.id;

    final map = <String, String>{
      'booking_date': bookingDate.toIso8601String().split('T').first,
      'service_id': service.id.toString(),
      'vendor_id': service.vendorId
          .toString(),
      'service_hour_id': slot.id.toString(),
      'start_time': start,
      'end_time': end,
      'amount': amountMajor.toStringAsFixed(2),
      'name': (mergedBilling['name'] ?? '').trim(),
      'phone': (mergedBilling['phone'] ?? '').trim(),
      'address': (mergedBilling['address'] ?? '').trim(),
      'zip_code': (mergedBilling['zip_code'] ?? '').trim(),
      'country': (mergedBilling['country'] ?? '').trim(),
      'email': (mergedBilling['email'] ?? '').trim(),
      'max_person': persons,
      'user_id': userId,
      'payment_method': method,
      'gateway_type': gatewayType,
      'payment_status': gatewayType.toLowerCase() == 'offline'
          ? 'pending'
          : 'completed',
      'staff_id': effectiveStaffId.toString(),
      'fcm_token': (mergedBilling['fcm_token'] ?? '').trim(),
    };

    return map;
  }
}
