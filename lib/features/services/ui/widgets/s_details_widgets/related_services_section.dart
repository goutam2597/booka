import 'package:bookapp_customer/features/services/providers/service_details_ui_provider.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:get/get.dart';
import 'related_list_view.dart';
import 'related_grid_view.dart';

class RelatedServicesSection extends StatelessWidget {
  const RelatedServicesSection({
    super.key,
    required this.services,
    required this.viewMode,
  });

  final List<ServicesModel> services;
  final ValueNotifier<RelatedViewMode> viewMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Related Services'.tr,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorText,
                  ),
                ),
                ValueListenableBuilder<RelatedViewMode>(
                  valueListenable: viewMode,
                  builder: (context, mode, _) {
                    final isList = mode == RelatedViewMode.list;
                    return ToggleButtons(
                      fillColor: AppColors.primaryColor,
                      selectedColor: Colors.white,
                      color: AppColors.primaryColor,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      isSelected: [isList, !isList],
                      onPressed: (index) {
                        viewMode.value = index == 0
                            ? RelatedViewMode.list
                            : RelatedViewMode.grid;
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.view_list_rounded, size: 24),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.grid_view_rounded, size: 24),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Body: switch between List and Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ValueListenableBuilder<RelatedViewMode>(
              valueListenable: viewMode,
              builder: (context, mode, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: mode == RelatedViewMode.list
                      ? RelatedListView(
                          services: services,
                          key: const ValueKey('list'),
                        )
                      : RelatedGridView(
                          services: services,
                          key: const ValueKey('grid'),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
