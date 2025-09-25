import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/home/data/models/notification_model.dart';
import 'package:bookapp_customer/features/home/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final String todayDate = DateFormat('dd MMM, yyyy').format(DateTime.now());
  final List<String> items = ['All', 'Read', 'Unread'];

  Widget _getIcon(String type) {
    final iconMap = {
      "Order": AssetsPath.orderHistorySvg,
      "Booking": AssetsPath.reservationSvg,
      "Payment": AssetsPath.walletSvg,
      "Schedule": AssetsPath.clockSvg,
    };

    return SvgPicture.asset(
      iconMap.entries
          .firstWhere(
            (e) => type.contains(e.key),
            orElse: () => MapEntry('', AssetsPath.notificationIconSvg),
          )
          .value,
      width: 24,
      height: 24,
      colorFilter:  ColorFilter.mode(
        AppColors.primaryColor,
        BlendMode.srcIn,
      ),
    );
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return "${diff.inSeconds} sec ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hour ago";
    if (diff.inDays == 1) return "Yesterday";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    return DateFormat('dd MMM, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final selectedValue = switch (provider.filter) {
      NotificationFilter.read => 'Read',
      NotificationFilter.unread => 'Unread',
      _ => 'All',
    };
    final List<NotificationModel> notifications = provider.notifications;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Notifications'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: DropdownButtonFormField(
                          borderRadius: BorderRadius.circular(8),
                          dropdownColor: Colors.white,
                          elevation: 2,
                          initialValue: selectedValue,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: items
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            switch (val) {
                              case 'Read':
                                provider.setFilter(NotificationFilter.read);
                                break;
                              case 'Unread':
                                provider.setFilter(NotificationFilter.unread);
                                break;
                              default:
                                provider.setFilter(NotificationFilter.all);
                            }
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (provider.filter == NotificationFilter.read) {
                            CustomSnackBar.show(
                              context,
                              'All notifications are already read!',
                            );
                            return;
                          }
                          await provider.markAllAsRead();
                          if (!context.mounted) return;
                          CustomSnackBar.show(
                            context,
                            provider.filter == NotificationFilter.unread
                                ? 'Mark as read'.tr
                                : 'Marked all as read'.tr,
                          );
                        },
                        child: Text(
                          'Mark All as Read'.tr,
                          style: AppTextStyles.bodyLargeGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${"Today".tr} $todayDate',
                    style: AppTextStyles.bodyLargeGrey,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            /// Notifications List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: notifications.isEmpty
                    ? const Center(child: Text('No notifications found!'))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          return Dismissible(
                            key: ValueKey(notification.hashCode),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) async {
                              final model = notification;
                              await context.read<NotificationProvider>()
                                  .removeNotification(model);
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => CustomSnackBar.show(
                                  context,
                                  'Notification removed successfully!',
                                ),
                              );
                            },
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (!notification.isRead) {
                                  await context
                                      .read<NotificationProvider>()
                                      .markAsRead(notification);
                                }
                                if (!context.mounted) return;
                                Get.toNamed(
                                  AppRoutes.notificationDetails,
                                  arguments: notification,
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.grey.shade100),
                                ),
                                elevation: 0.1,
                                color: notification.isRead
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icon with badge
                                      Stack(
                                        children: [
                                          Container(
                                            height: 56,
                                            width: 56,
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: _getIcon(notification.type),
                                          ),
                                          if (!notification.isRead)
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: Container(
                                                height: 16,
                                                width: 16,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),

                                      // Text Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notification.title,
                                                    style: AppTextStyles
                                                        .headingSmall
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  timeAgo(
                                                    notification.timestamp,
                                                  ),
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              notification.body,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    fontSize: 16,
                                                    color: AppColors.primaryColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
