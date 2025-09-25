import 'dart:async';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_controller.dart';
import 'package:bookapp_customer/network_service/core/basic_service.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Provider that mirrors the previous internal state of `PaymentScreen`.
/// No business logic changed; only lifted into a ChangeNotifier.
class PaymentScreenProvider extends ChangeNotifier {
  PaymentScreenProvider({
    required this.service,
    required this.staff,
    required this.bookingDate,
    required this.bookingTime,
    required this.billingDetails,
    required this.totalAmountMinor,
    required this.onPaymentComplete,
    required this.readAuth,
  });

  final ServicesModel service;
  final StaffModel staff;
  final DateTime bookingDate;
  final AvailableTimeResponseModel bookingTime;
  final Map<String, String> billingDetails;
  final int totalAmountMinor;
  final void Function(String method, String? bookingId) onPaymentComplete;
  final AuthProvider Function() readAuth;

  PaymentController? _controller;
  PaymentController? get controller => _controller;

  bool _busy = false;
  bool get busy => _busy;

  String _appCurrency = 'USD';
  String get appCurrency => _appCurrency;

  final Set<GatewayType> _apiGateways = <GatewayType>{};
  Set<GatewayType> get apiGateways => _apiGateways;

  final List<Map<String, dynamic>> _offlineGateways = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> get offlineGateways =>
      List.unmodifiable(_offlineGateways);

  bool _initialized = false;
  bool get initialized => _initialized;

  double get amountMajor => double.tryParse(totalAmountMinor.toString()) ?? 0.0;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final basic = await BasicService.fetchBasic();
      final currency =
          (basic?['data']?['basic_data']?['base_currency_text']
              ?.toString()
              .trim()) ??
          '';

      // Online gateways
      final og = basic?['data']?['online_gateways'];
      if (og is List) {
        _apiGateways.clear();
        for (final item in og) {
          try {
            final map = (item as Map).cast<String, dynamic>();
            final kw = map['keyword']?.toString() ?? '';
            final g = gatewayFromApiKeyword(kw);
            if (g != null) _apiGateways.add(g);
          } catch (_) {}
        }
      }

      // Offline gateways
      final off = basic?['data']?['offline_gateways'];
      _offlineGateways.clear();
      if (off is List) {
        for (final item in off) {
          try {
            final m = (item as Map).cast<String, dynamic>();
            final name = (m['name'] ?? m['title'] ?? '').toString();
            final desc = (m['instructions'] ?? m['description'] ?? '')
                .toString();
            final attachField = (m['attachment_field'] ?? 'attachment')
                .toString();
            final hasAttachRaw =
                (m['has_attachment'] ??
                        m['attachment_required'] ??
                        m['is_attachment'] ??
                        '0')
                    .toString()
                    .trim()
                    .toLowerCase();
            final hasAttach =
                hasAttachRaw == '1' ||
                hasAttachRaw == 'true' ||
                hasAttachRaw == 'yes';
            if (name.isNotEmpty) {
              _offlineGateways.add({
                'name': name,
                'instructions': desc,
                'attachment_field': attachField,
                'has_attachment': hasAttach ? '1' : '0',
              });
            }
          } catch (_) {}
        }
      }

      _appCurrency = currency.toUpperCase();
      _controller = PaymentController(
        currency: _appCurrency,
        service: service,
        staff: staff,
        bookingDate: bookingDate,
        slot: bookingTime,
        billingDetails: billingDetails,
        totalAmountMinor: totalAmountMinor,
        readAuth: readAuth,
        onComplete: onPaymentComplete,
        onUserCancel: () {
          final ctx = Get.context;
          if (ctx != null) {
            CustomSnackBar.show(
              ctx,
              'Payment cancelled'.tr,
              backgroundColor: Colors.black,
              iconBgColor: AppColors.snackError,
              icon: Icons.close,
            );
          }
        },
        onError: (msg) {
          final ctx = Get.context;
          if (ctx != null) {
            CustomSnackBar.show(
              ctx,
              msg,
              backgroundColor: Colors.black,
              iconBgColor: AppColors.snackError,
              icon: Icons.error_outline,
            );
          }
        },
        onSuccessToast: () {
          final ctx = Get.context;
          if (ctx != null) {
            CustomSnackBar.show(
              ctx,
              'Payment successful'.tr,
              backgroundColor: Colors.black,
              iconBgColor: AppColors.snackSuccess,
              icon: Icons.check_circle_outline,
            );
          }
        },
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> run(Future<void> Function() fn) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      await fn();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  bool show(GatewayType g) => _apiGateways.contains(g);
}
