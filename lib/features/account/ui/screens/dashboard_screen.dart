import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/account/providers/dashboard_provider.dart';
import 'package:bookapp_customer/features/account/ui/widgets/dashboard_summary_card_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/information_card_widget.dart';

import '../../../../app/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  final int userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, prov, _) {
          if (!prov.isLoggedIn) {
            return const Center(child: Text("Please login to view dashboard"));
          }
          if (prov.isLoading && prov.dashboard == null) {
            return const Center(child: CustomCPI());
          }
          if (prov.error != null && prov.dashboard == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(prov.error!),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton(
                      onPressed: prov.refresh,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            );
          }

          final dashboardData = prov.dashboard!;
          return Column(
            children: [
              CustomAppBar(title: dashboardData.pageTitle),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: AppColors.primaryColor,
                  onRefresh: prov.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DashboardSummaryCardWidget(
                                iconSvg: AssetsPath.totalAppointmentSvg,
                                qty: dashboardData.appointmentsCount.toString(),
                                cardTitle: "${'Total'.tr}\n${'Appointments'.tr}",
                                onTap: () => Get.toNamed(
                                  AppRoutes.bottomNav,
                                  arguments: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DashboardSummaryCardWidget(
                                iconSvg: AssetsPath.wishListSvg,
                                qty: dashboardData.wishlistsCount.toString(),
                                cardTitle: "${'Total'.tr}\n${'Wishlists'.tr}",
                                onTap: () => Get.toNamed(
                                  AppRoutes.wishlist,
                                  arguments: dashboardData.userModel.id,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InformationCardWidget(
                          leftFlex: 3,
                          rightFlex: 6,
                          cardTitle: 'Account Information',
                          infoEntries: [
                            MapEntry(
                              'Username',
                              dashboardData.userModel.username ?? '',
                            ),
                            MapEntry('Name', dashboardData.userName),
                            MapEntry('Email', dashboardData.userEmail),
                            MapEntry(
                              'Phone',
                              dashboardData.userModel.phone ?? '',
                            ),
                            MapEntry(
                              'City',
                              dashboardData.userModel.city ?? '',
                            ),
                            MapEntry(
                              'Zip Code',
                              dashboardData.userModel.zipCode ?? '',
                            ),
                            MapEntry(
                              'Address',
                              dashboardData.userModel.address ?? '',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
