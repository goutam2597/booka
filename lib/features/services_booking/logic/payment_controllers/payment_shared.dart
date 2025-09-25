import 'dart:async';
import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:bookapp_customer/app/app_strings.dart';
import 'package:bookapp_customer/network_service/core/checkout_services.dart'
    show CheckoutService;
import 'package:bookapp_customer/features/services_booking/logic/payload_builder.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/progress_overlay.dart';
import 'package:bookapp_customer/network_service/core/notification_service.dart'
    show NotificationService;
import 'package:flutter/material.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/offline_gateway_dialog.dart';

class PaymentCancelled implements Exception {
  @override
  String toString() => 'PaymentCancelled';
}

class PaymentException implements Exception {
  final String code;
  final String message;
  PaymentException(this.code, this.message);
  @override
  String toString() => message;
}

class PaymentShared {
  PaymentShared(this.ctx);
  final PaymentContext ctx;

  double get _amountMajorRequested =>
      double.tryParse(ctx.totalAmountMinor.toString()) ?? 0.0;

  String fmtDate(DateTime d) => d.toIso8601String().split('T').first;

  bool supports(GatewayType g) {
    final app = ctx.currency.toUpperCase().trim();
    final set = ctx.supportedCurrencies[g] ?? const {};
    return set.contains(app) || set.contains('USD');
  }

  String selectCurrencyOrThrow(GatewayType g) {
    final app = ctx.currency.toUpperCase().trim();
    final set = ctx.supportedCurrencies[g] ?? const {};
    if (set.contains(app)) return app;
    if (set.contains('USD')) return 'USD';
    final label = gatewayLabel(g);
    throw PaymentException(
      'currency_unsupported',
      '$label does not support the app currency ($app) and USD is not available.',
    );
  }

  void ensureCurrencySupported(GatewayType g) {
    if (supports(g)) return;
    final label = gatewayLabel(g);
    final ccy = ctx.currency.toUpperCase().trim();
    throw PaymentException(
      'currency_unsupported',
      '$label does not support $ccy.',
    );
  }

  Map<String, String> mergedBilling(BuildContext context) {
    String? profName, profEmail, profPhone, profAddress;
    try {
      final u = ctx.readAuth().dashboard?.userModel;
      if (u != null) {
        profName = u.name;
        profEmail = u.email;
        profPhone = u.phone;
        profAddress = u.address;
      }
    } catch (_) {}

    String pref(String? form, String? prof, String fallback) {
      if (form != null && form.trim().isNotEmpty) return form.trim();
      if (prof != null && prof.trim().isNotEmpty) return prof.trim();
      return fallback;
    }

    final nameForm =
        ctx.billingDetails['name'] ?? ctx.billingDetails['fullName'];
    final emailForm = ctx.billingDetails['email'];
    final phoneForm =
        ctx.billingDetails['phone'] ?? ctx.billingDetails['phoneNumber'];
    final addressForm = ctx.billingDetails['address'];

    return {
      'name': pref(nameForm, profName, 'User'),
      'email': pref(emailForm, profEmail, 'customer@example.com'),
      'phone': pref(phoneForm, profPhone, ''),
      'address': pref(addressForm, profAddress, ''),
      'zip_code': ctx.billingDetails['zip_code']?.trim() ?? '',
      'country': ctx.billingDetails['country']?.trim() ?? '',
      'fcm_token': NotificationService.currentToken ?? '',
    };
  }

  String? resolveUserId() {
    try {
      final uid = ctx.readAuth().dashboard?.userModel.id;
      if (uid != null && uid > 0) return uid.toString();
    } catch (_) {}
    final fromBilling = ctx.billingDetails['user_id'];
    if (fromBilling != null && fromBilling.isNotEmpty) return fromBilling;
    return null;
  }

  String? resolveBearerToken() => null;

  String? bookingIdFromResponse(Map<String, dynamic> resp) {
    try {
      final data = resp['data'];
      if (data is String && data.trim().isNotEmpty) return data.trim();
      if (data is Map) {
        final id = data['id'] ?? data['booking_id'] ?? data['bookingId'];
        if (id != null && '$id'.trim().isNotEmpty) return '$id';
      }
      final id = resp['booking_id'] ?? resp['id'];
      if (id != null && '$id'.trim().isNotEmpty) return '$id';
    } catch (_) {}
    return null;
  }

  Future<num> verifyOrThrow(ProgressOverlay overlay) async {
    overlay.update(PaymentStrings.verifyingAmount);
    final String requestMajor = _amountMajorRequested.toStringAsFixed(2);

    final num verified = await CheckoutService.verifyPaymentSmart(
      amountRaw: requestMajor,
      vendorId: ctx.service.vendorId,
      bookingDate: fmtDate(ctx.bookingDate),
    ).timeout(const Duration(seconds: 10));

    if (verified <= 0) {
      throw PaymentException(
        'verify_failed',
        'Verification returned an invalid amount.',
      );
    }
    if (verified.toStringAsFixed(2) != requestMajor) {
      overlay.update(
        PaymentStrings.priceUpdatedTo(verified.toStringAsFixed(2)),
      );
      await Future.delayed(const Duration(milliseconds: 350));
    }
    return verified;
  }

  /// Verify using server with a specific gateway type (as required by backend)
  Future<num> verifyForGatewayOrThrow(
    GatewayType gateway,
    ProgressOverlay overlay,
  ) async {
    overlay.update(PaymentStrings.verifyingAmount);
    final String requestMajor = _amountMajorRequested.toStringAsFixed(2);
    final num verified = await CheckoutService.verifyPaymentForGateway(
      amountRaw: requestMajor,
      gatewayKeyword: gatewayKeyword(gateway),
      vendorId: ctx.service.vendorId,
      bookingDate: fmtDate(ctx.bookingDate),
    ).timeout(const Duration(seconds: 10));
    if (verified <= 0) {
      throw PaymentException(
        'verify_failed',
        'Verification returned an invalid amount.',
      );
    }
    if (verified.toStringAsFixed(2) != requestMajor) {
      overlay.update(
        PaymentStrings.priceUpdatedTo(verified.toStringAsFixed(2)),
      );
      await Future.delayed(const Duration(milliseconds: 350));
    }
    return verified;
  }

  Future<void> runHostedGateway({
    required BuildContext context,
    required GatewayType gateway,
    required String openingLabel,
    required String methodLabel,
    required Future<bool> Function(
      BuildContext ctx,
      Map<String, String> merged,
      num verifiedAmount,
      int verifiedMinor,
      String selectedCcyLower,
    )
    openAndConfirm,
  }) async {
    final overlay = ProgressOverlay.of(context);
    overlay.show(PaymentStrings.checkingCurrency);
    try {
      final selectedCcy = selectCurrencyOrThrow(gateway);

      overlay.update(PaymentStrings.verifyingAmount);
      // Verify using the tapped gateway keyword so backend can apply gateway-specific logic
      final String gwKey = gatewayKeyword(gateway);
      final String requestMajor = _amountMajorRequested.toStringAsFixed(2);
      final num verifiedAmount = await CheckoutService.verifyPaymentForGateway(
        amountRaw: requestMajor,
        gatewayKeyword: gwKey,
        vendorId: ctx.service.vendorId,
        bookingDate: fmtDate(ctx.bookingDate),
      ).timeout(const Duration(seconds: 10));
      if (verifiedAmount <= 0) {
        throw PaymentException(
          'verify_failed',
          'Verification returned an invalid amount.',
        );
      }
      if (verifiedAmount.toStringAsFixed(2) != requestMajor) {
        overlay.update(
          PaymentStrings.priceUpdatedTo(verifiedAmount.toStringAsFixed(2)),
        );
        await Future.delayed(const Duration(milliseconds: 350));
      }
      final int verifiedMinor = (verifiedAmount * 100).round();

      await Future.delayed(const Duration(milliseconds: 150));
      overlay.update(PaymentStrings.opening(openingLabel));

      if (!context.mounted) return;
      final merged = mergedBilling(context);

      final ok = await openAndConfirm(
        context,
        merged,
        verifiedAmount,
        verifiedMinor,
        selectedCcy.toLowerCase(),
      );

      if (!ok) throw PaymentCancelled();

      overlay.update(PaymentStrings.finalizingBooking);

      final userId = resolveUserId();
      final bearer = resolveBearerToken();

      final payload = BookingPayload.build(
        amountMajor: verifiedAmount.toDouble(),
        service: ctx.service,
        staff: ctx.staff,
        bookingDate: ctx.bookingDate,
        slot: ctx.slot,
        mergedBilling: merged,
        persons: ctx.billingDetails['persons'] ?? '1',
        userId: userId ?? '0',
        method: methodLabel,
        gatewayType: 'online',
      );

      final resp = await CheckoutService.paymentProcess(
        payload,
        bearerToken: bearer,
      );
      final bookingId = bookingIdFromResponse(resp);

      ctx.onComplete(methodLabel, bookingId);
      ctx.onSuccessToast();
    } on TimeoutException {
      ctx.onError(PaymentStrings.verifyTimeout);
    } on PaymentCancelled {
      ctx.onUserCancel();
    } on PaymentException catch (e) {
      ctx.onError(e.message);
    } catch (e) {
      ctx.onError('${PaymentStrings.paymentNotSuccessful} $e');
    } finally {
      overlay.hide();
    }
  }

  // ---------------------- OFFLINE PAYMENT ----------------------
  Future<void> runOfflinePayment({
    required BuildContext context,
    required String gatewayName,
    String instructions = '',
    String attachmentFieldName = 'attachment',
    bool showAttachment = true,
    bool attachmentRequired = false,
  }) async {
    final overlay = ProgressOverlay.of(context);
    overlay.show(PaymentStrings.verifyingAmount);
    try {
      final String requestMajor = _amountMajorRequested.toStringAsFixed(2);
      final num verifiedAmount = await CheckoutService.verifyPaymentSmart(
        amountRaw: requestMajor,
        vendorId: ctx.service.vendorId,
        bookingDate: fmtDate(ctx.bookingDate),
      ).timeout(const Duration(seconds: 15));
      if (verifiedAmount <= 0) {
        throw PaymentException(
          'verify_failed',
          'Verification returned an invalid amount.',
        );
      }
      if (!context.mounted) return;
      final merged = mergedBilling(context);

      // Open dialog to collect customer name and optional attachment
      overlay.hide();
      if (!context.mounted) return;
      final result = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (_) => OfflineGatewayDialog(
          gatewayName: gatewayName,
          instructions: instructions,
          initialName: merged['name'],
          attachmentFieldName: attachmentFieldName,
          showAttachment: showAttachment,
          attachmentRequired: attachmentRequired,
        ),
      );
      overlay.show(PaymentStrings.finalizingBooking);
      if (result == null) {
        throw PaymentCancelled();
      }

      final String name =
          (result['name'] as String?)?.trim() ?? merged['name'] ?? 'User';
      final String? filePath = (result['filePath'] as String?);
      final String attachmentField =
          (result['attachmentField'] as String?) ?? attachmentFieldName;

      // Build payload with offline gateway
      final userId = resolveUserId();
      final bearer = resolveBearerToken();
      final payload = BookingPayload.build(
        amountMajor: (verifiedAmount.toDouble()),
        service: ctx.service,
        staff: ctx.staff,
        bookingDate: ctx.bookingDate,
        slot: ctx.slot,
        mergedBilling: {...merged, 'name': name},
        persons: ctx.billingDetails['persons'] ?? '1',
        userId: userId ?? '0',
        method: gatewayName,
        gatewayType: 'offline',
      );

      final files = <String, String>{};
      if (filePath != null && filePath.trim().isNotEmpty) {
        files[attachmentField] = filePath;
      }

      final resp = await CheckoutService.paymentProcess(
        payload,
        bearerToken: bearer,
        filePaths: files.isEmpty ? null : files,
      );

      final bookingId = bookingIdFromResponse(resp);
      ctx.onComplete(gatewayName, bookingId);
      ctx.onSuccessToast();
    } on TimeoutException {
      ctx.onError(PaymentStrings.verifyTimeout);
    } on PaymentCancelled {
      ctx.onUserCancel();
    } on PaymentException catch (e) {
      ctx.onError(e.message);
    } catch (e) {
      ctx.onError('${PaymentStrings.paymentNotSuccessful} $e');
    } finally {
      overlay.hide();
    }
  }
}
