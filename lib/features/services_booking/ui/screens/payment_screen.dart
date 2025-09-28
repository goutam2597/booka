import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_controller.dart';
import 'package:bookapp_customer/features/services_booking/providers/payment_screen_provider.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatelessWidget {
  final void Function(String paymentMethod, String? bookingId)
  onPaymentComplete;
  final ServicesModel service;
  final StaffModel staff;
  final DateTime bookingDate;
  final AvailableTimeResponseModel bookingTime;
  final Map<String, String> billingDetails;
  final int totalAmount;
  final VoidCallback onBack;

  const PaymentScreen({
    super.key,
    required this.service,
    required this.staff,
    required this.bookingDate,
    required this.bookingTime,
    required this.billingDetails,
    required this.totalAmount,
    required this.onPaymentComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PaymentScreenProvider(
        service: service,
        staff: staff,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        billingDetails: billingDetails,
        totalAmountMinor: totalAmount,
        onPaymentComplete: onPaymentComplete,
        readAuth: () => ctx.read<AuthProvider>(),
      )..init(),
      builder: (context, _) {
        final p = context.watch<PaymentScreenProvider>();
        final PaymentController? controller = p.controller;
        final currencyCode = p.appCurrency;
        bool show(GatewayType g) => p.show(g);
        final offline = p.offlineGateways;
        final amountMajor = p.amountMajor;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) onBack();
          },
          child: Scaffold(
            body: SafeArea(
              child: controller == null
                  ? const Center(child: CustomCPI())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '${'Payable Amount'.tr} $currencyCode ${amountMajor.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyLargeGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Select Payment Method'.tr,
                              style: AppTextStyles.headingLarge,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Google Pay temporarily disabled

                          if (show(GatewayType.paypal)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwPaypalSvg,
                              label: 'PayPal',
                              onTap: () => p.run(
                                () => controller.payWithPayPal(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.stripe)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwStripeSvg,
                              label: 'Stripe',
                              onTap: () => p.run(
                                () => controller.payWithStripe(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.flutterWave)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwFlutterwaveSvg,
                              label: 'Flutterwave',
                              onTap: () => p.run(
                                () => controller.payWithFlutterwave(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.razorpay)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwRazorpaySvg,
                              label: 'Razorpay',
                              onTap: () => p.run(
                                () => controller.payWithRazorpaySdk(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.phonePe)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwPhonePaySvg,
                              label: 'PhonePe',
                              onTap: () => p.run(
                                () => controller.payWithPhonePe(context),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Other gateways
                          if (show(GatewayType.myfatoorah)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwMyfatoorah,
                              label: 'MyFatoorah',
                              onTap: () => p.run(
                                () => controller.payWithMyFatoorah(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.payStack)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwPaystackSvg,
                              label: 'Paystack',
                              onTap: () => p.run(
                                () => controller.payWithPayStack(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.mollie)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwMollieSvg,
                              label: 'Mollie',
                              onTap: () => p.run(
                                () => controller.payWithMollie(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.xendit)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwXenditSvg,
                              label: 'Xendit',
                              onTap: () => p.run(
                                () => controller.payWithXendit(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.authorize_net)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwAuthorizeNetSvg,
                              label: 'Authorize.net',
                              onTap: () => p.run(
                                () => controller.payWithAuthorizeNet(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.toyyibpay)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwToyyibpaySvg,
                              label: 'Toyyibpay',
                              onTap: () => p.run(
                                () => controller.payWithToyyibpay(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.midtrans)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwMidtransSvg,
                              label: 'MidTrans',
                              onTap: () => p.run(
                                () => controller.payWithMidtrans(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.mercadoPago)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwMercadoPagoSvg,
                              label: 'MercadoPago',
                              onTap: () => p.run(
                                () => controller.payWithMercadoPago(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (show(GatewayType.monnify)) ...[
                            WalletCard(
                              asset: AssetsPath.pgwMonnifySvg,
                              label: 'Monnify',
                              onTap: () => p.run(
                                () => controller.payWithMonnify(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // PayTabs removed
                          if (show(GatewayType.nowPayments))
                            WalletCard(
                              asset: AssetsPath.pgwNowPaymentSvg,
                              label: 'NOW Payments',
                              onTap: () => p.run(
                                () => controller.payWithNowPayments(context),
                              ),
                            ),

                          const SizedBox(height: 8),

                          if (offline.isNotEmpty) ...[
                            Center(
                              child: Text(
                                'Pay Offline'.tr,
                                style: AppTextStyles.headingLarge,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final gw in offline) ...[
                              WalletCard(
                                asset: AssetsPath.walletSvg,
                                label: gw['name']?.toString() ?? 'Offline',
                                onTap: () => p.run(() async {
                                  final name =
                                      gw['name']?.toString() ?? 'Offline';
                                  final instructions =
                                      gw['instructions']?.toString() ?? '';
                                  final attachField =
                                      gw['attachment_field']?.toString() ??
                                      'attachment';
                                  final hasAttach =
                                      (gw['has_attachment']?.toString() ?? '0')
                                          .trim() ==
                                      '1';
                                  await controller.payWithOffline(
                                    context,
                                    gatewayName: name,
                                    instructions: instructions,
                                    attachmentFieldName: attachField,
                                    showAttachment: hasAttach,
                                    attachmentRequired: hasAttach,
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
