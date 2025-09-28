import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/account/ui/widgets/dashboard_item.dart';
import 'package:bookapp_customer/features/account/ui/widgets/profile_card.dart';
import 'package:bookapp_customer/features/account/ui/widgets/profile_card_loading.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bookapp_customer/features/common/providers/nav_provider.dart';

import '../../../../app/routes/app_routes.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  List<Map<String, dynamic>> get _items => const [
    {'title': 'Dashboard', 'icon': FontAwesomeIcons.gauge},
    {'title': 'Edit Profile', 'icon': FontAwesomeIcons.solidUser},
    {'title': 'My Wishlist', 'icon': FontAwesomeIcons.solidHeart},
    {'title': 'Appointments', 'icon': FontAwesomeIcons.solidCalendarCheck},
    {'title': 'Settings', 'icon': FontAwesomeIcons.gear},
    {'title': 'Change Password', 'icon': FontAwesomeIcons.lock},
    {'title': 'Logout', 'icon': FontAwesomeIcons.rightFromBracket},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // If the user is not logged in, redirect to login and show an empty view.
    if (!auth.isLoggedIn) {
      // Defer navigation to next frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Get.toNamed(AppRoutes.login);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: 'Account',
            onTap: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAllNamed(AppRoutes.bottomNav);
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Account Information'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _profileCard(auth),
                  const SizedBox(height: 16),
                  _list(context, auth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(AuthProvider auth) {
    if (!auth.isLoggedIn) return const SizedBox.shrink();
    if (auth.loadingDashboard) return const ProfileCardLoadingState();
    if (auth.dashboard != null) {
      return ProfileCard(accountData: auth.dashboard!);
    }
    return const ProfileCardLoadingState();
  }

  Widget _list(BuildContext context, AuthProvider auth) {
    return Card(
      elevation: 0.5,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, _) =>
            Divider(thickness: 1.5, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final item = _items[index];
          return DashboardItem(
            title: item['title'] as String,
            icon: item['icon'] as IconData,
            onTap: () async {
              Future<void> doAction() async {
                switch (item['title']) {
                  case 'Dashboard':
                    if (auth.dashboard != null && context.mounted) {
                      Get.toNamed(
                        AppRoutes.dashboard,
                        arguments: auth.dashboard!.userModel.id,
                      );
                    }
                    break;
                  case 'Edit Profile':
                    final updated =
                        await Get.toNamed(AppRoutes.editProfile) as bool?;
                    if (updated == true && context.mounted) {
                      await context.read<AuthProvider>().refreshDashboard();
                    }
                    break;
                  case 'My Wishlist':
                    if (auth.dashboard != null && context.mounted) {
                      Get.toNamed(
                        AppRoutes.wishlist,
                        arguments: auth.dashboard!.userModel.id,
                      );
                    }
                    break;
                  case 'Appointments':
                    if (context.mounted) {
                      context.read<NavProvider>().setIndex(2);
                    }
                    break;
                  case 'Settings':
                    Get.toNamed(AppRoutes.settings);
                    break;
                  case 'Change Password':
                    Get.toNamed(AppRoutes.resetPassword);
                    break;
                  case 'Logout':
                    _logoutDialog(context);
                    break;
                }
              }

              const authItems = {
                'Dashboard',
                'Edit Profile',
                'My Wishlist',
                'Appointments',
                'Change Password',
              };

              if (!auth.isLoggedIn && authItems.contains(item['title'])) {
                await Get.toNamed(AppRoutes.login);
                if (context.mounted &&
                    context.read<AuthProvider>().isLoggedIn) {
                  await doAction();
                }
                return;
              }

              await doAction();
            },
          );
        },
      ),
    );
  }

  void _logoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Close".tr),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pop(ctx);
                Get.offAllNamed(AppRoutes.bottomNav);
              }
            },
            child: Text("Logout".tr),
          ),
        ],
      ),
    );
  }
}
