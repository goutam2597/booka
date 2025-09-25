import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:bookapp_customer/features/appointments/models/appointment_details_model.dart';
import 'package:bookapp_customer/network_service/core/appointments_service.dart';

class AppointmentDetailsProvider extends ChangeNotifier {
  final Map<int, AppointmentDetailsModel> _cache = {};
  final Map<int, bool> _loading = {};
  final Map<int, String?> _error = {};

  AppointmentDetailsModel? get(int id) => _cache[id];
  bool loading(int id) => _loading[id] == true;
  String? error(int id) => _error[id];

  void _safeNotify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle) {
      // no frame currently building — safe to notify
      notifyListeners();
    } else {
      // schedule the notification after this frame finishes
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  Future<void> fetch(int id, {bool force = false}) async {
    // Prevent overlapping/duplicate requests for the same id.
    if (loading(id)) return;

    // If we already have good data and not forcing, skip.
    if (!force && _cache.containsKey(id) && _error[id] == null) return;

    _loading[id] = true;
    _error[id] = null;
    _safeNotify();

    try {
      final details = await AppointmentsService.getAppointmentDetails(id);
      _cache[id] = details;
      _error[id] = null;
    } catch (_) {
      _error[id] = 'Error fetching details';
      _cache.remove(id);
    } finally {
      _loading[id] = false;
      _safeNotify();
    }
  }

  Future<void> refresh(int id) => fetch(id, force: true);

  void invalidate(int id) {
    _cache.remove(id);
    _error.remove(id);
    _safeNotify();
  }
}
