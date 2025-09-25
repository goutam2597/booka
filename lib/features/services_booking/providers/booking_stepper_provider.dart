import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';

/// Provider that encapsulates the booking multi-step flow state which was
/// previously held inside a StatefulWidget (CustomStepperScreen).
///
/// Logic & flow ordering preserved exactly. No business rule changes.
class BookingStepperProvider extends ChangeNotifier {
  BookingStepperProvider({required this.selectedService});

  final ServicesModel selectedService;

  int activeStep = 1; // 1..6 logical steps
  int currentSubScreen = 0; // for step 3 (login/billing) sub-screens

  StaffModel? selectedStaff;
  DateTime? selectedDate;
  AvailableTimeResponseModel? selectedTimeSlot;
  int? selectedPersons;
  String? selectedPayment;
  String? bookingId;

  Map<String, String>? billingDetails;
  int? totalAmount;

  bool _isForward = true;
  int _lastFlowIndex = 10; // used to compute slide direction
  bool get isForward => _isForward;

  void _updateDirection(int nextIndex) {
    _isForward = nextIndex >= _lastFlowIndex;
    _lastFlowIndex = nextIndex;
  }

  // ----- Flow transitions -----
  void onStaffSelected(StaffModel staff) {
    final nextStep = 2;
    final nextSub = 0;
    selectedStaff = staff;
    activeStep = nextStep;
    currentSubScreen = nextSub;
    _updateDirection(nextStep * 10 + nextSub);
    notifyListeners();
  }

  void onDateSlotSelected(DateTime date, AvailableTimeResponseModel slot, int persons) {
    final nextStep = 3;
    final nextSub = 0;
    selectedDate = date;
    selectedTimeSlot = slot;
    selectedPersons = persons;
    activeStep = nextStep;
    currentSubScreen = nextSub;
    _updateDirection(nextStep * 10 + nextSub);
    notifyListeners();
  }

  void goToPreviousStep() {
    if (activeStep == 2) {
      activeStep = 1;
      currentSubScreen = 0;
      _updateDirection(10);
    } else if (activeStep == 3) {
      if (currentSubScreen > 0) {
        final nextSub = currentSubScreen - 1;
        currentSubScreen = nextSub;
        _updateDirection(activeStep * 10 + nextSub);
      } else {
        activeStep = 2;
        currentSubScreen = 0;
        _updateDirection(20);
      }
    } else if (activeStep == 4) {
      activeStep = 3;
      currentSubScreen = 1; // go back to billing
      _updateDirection(31);
    } else if (activeStep == 5) {
      activeStep = 4;
      _updateDirection(40);
    } else if (activeStep == 6) {
      activeStep = 5;
      _updateDirection(50);
    } else {
      // root back navigation will be handled by screen scaffold
    }
    notifyListeners();
  }

  void handleBillingNext(Map<String, String> billing, int amount) {
    billingDetails = {
      ...billing,
      'persons': (selectedPersons ?? 1).toString(),
    };
    totalAmount = amount;
    activeStep = 4; // Order Summary
    _updateDirection(40);
    notifyListeners();
  }

  void handleLoginNext() {
    // Move to billing sub-screen after login
    goToNextStep();
    currentSubScreen = 1;
    _updateDirection(31);
    notifyListeners();
  }

  void goToNextStep() {
    if (activeStep == 3) {
      if (currentSubScreen < 1) {
        final nextSub = currentSubScreen + 1;
        currentSubScreen = nextSub;
        _updateDirection(activeStep * 10 + nextSub);
      } else {
        final nextStep = 4;
        activeStep = nextStep;
        _updateDirection(nextStep * 10 + currentSubScreen);
      }
    } else if (activeStep == 4) {
      activeStep = 5;
      _updateDirection(50);
    } else if (activeStep == 5) {
      activeStep = 6;
      _updateDirection(60);
    }
    notifyListeners();
  }

  void handleOrderSummaryNext() {
    activeStep = 5; // payment
    _updateDirection(50);
    notifyListeners();
  }

  void handlePaymentComplete(String paymentMethod, String? id) {
    selectedPayment = paymentMethod;
    bookingId = id;
    activeStep = 6; // confirmation
    _updateDirection(60);
    notifyListeners();
  }

  int get stepDisplayIndex => activeStep >= 6 ? 6 : activeStep;

  String slotToLabel(AvailableTimeResponseModel? slot) {
    if (slot == null) return '-';
    String? v;
    try { v = (slot as dynamic).time; } catch (_) {}
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    try { v = (slot as dynamic).timeRange; } catch (_) {}
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    try { v = (slot as dynamic).label; } catch (_) {}
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    try { v = (slot as dynamic).startTime; } catch (_) {}
    try {
      final end = (slot as dynamic).endTime;
      if ((v ?? '').toString().isNotEmpty && (end ?? '').toString().isNotEmpty) {
        return "${v.toString()} - ${end.toString()}";
      }
    } catch (_) {}
    try { final id = (slot as dynamic).id; if (id != null) return '#$id'; } catch(_) {}
    return '-';
  }

  bool get showBillingDirect => AuthAndNetworkService.isLoggedIn.value;
}
