import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/network_service/core/booking_network_service.dart';

class DateTimeSelectionProvider extends ChangeNotifier {
  DateTimeSelectionProvider({required this.service, required this.staff});

  final ServicesModel service;
  final StaffModel staff;

  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  AvailableTimeResponseModel? selectedTime;
  Future<List<AvailableTimeResponseModel>>? availableHoursFuture;
  int? selectedPersons;
  Set<int> globalWeekend = {DateTime.saturday, DateTime.sunday};

  bool _initStarted = false;

  Future<void> init() async {
    if (_initStarted) return; // only once
    _initStarted = true;
    await _loadGlobalWeekend();
  }

  bool isWeekend(DateTime day) => globalWeekend.contains(day.weekday);

  Future<void> _loadGlobalWeekend() async {
    try {
      final cfg = await BookingNetworkService.getDateTimeConfig(
        vendorId: service.vendorId,
        serviceId: service.id,
      );
      if (cfg == null) return;
      final mapped = <int>{};
      for (final raw in cfg.globalWeekend) {
        final v = (raw).toString().trim().toLowerCase();
        if (v.isEmpty) continue;
        switch (v) {
          case 'mon':
          case 'monday':
            mapped.add(DateTime.monday); break;
          case 'tue':
          case 'tuesday':
            mapped.add(DateTime.tuesday); break;
          case 'wed':
          case 'wednesday':
            mapped.add(DateTime.wednesday); break;
          case 'thu':
          case 'thursday':
            mapped.add(DateTime.thursday); break;
          case 'fri':
          case 'friday':
            mapped.add(DateTime.friday); break;
          case 'sat':
          case 'saturday':
            mapped.add(DateTime.saturday); break;
          case 'sun':
          case 'sunday':
            mapped.add(DateTime.sunday); break;
          default:
            final n = int.tryParse(v);
            if (n != null && n >= 1 && n <= 7) mapped.add(n);
        }
      }
      if (mapped.isNotEmpty) {
        globalWeekend = mapped;
        notifyListeners();
      }
    } catch (_) {}
  }

  void fetchHoursForDate(DateTime date) {
    final dayName = DateFormat('EEEE').format(date);
    final bookingDate = DateFormat('yyyy-MM-dd').format(date);
    availableHoursFuture = BookingNetworkService.getStaffAvailableTimes(
      dayName: dayName,
      staffId: staff.id,
      bookingDate: bookingDate,
      vendorId: service.vendorId,
      serviceId: service.id,
    );
    selectedTime = null;
    selectedPersons = null;
    notifyListeners();
  }

  void selectDate(DateTime day, DateTime focused) {
    selectedDate = day;
    focusedDay = focused;
    notifyListeners();
  }

  void selectTime(AvailableTimeResponseModel slot) {
    selectedTime = slot;
    notifyListeners();
  }

  void selectPersons(int persons) {
    selectedPersons = persons;
    notifyListeners();
  }
}
