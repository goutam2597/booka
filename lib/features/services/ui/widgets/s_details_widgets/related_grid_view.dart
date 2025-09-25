import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/ui/widgets/services_card_widget_for_grid.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';

class RelatedGridView extends StatelessWidget {
  const RelatedGridView({super.key, required this.services});
  final List<ServicesModel> services;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 8;
          final itemWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(services.length, (index) {
              final item = services[index];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 500),
                columnCount: 2,
                child: ScaleAnimation(
                  scale: 0.85,
                  child: FadeInAnimation(
                    child: SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.serviceDetails,
                            arguments: {'slug': item.slug, 'id': item.id},
                            preventDuplicates: false,
                          );
                        },
                        child: ServicesCardWidgetForGrid(item: item),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
