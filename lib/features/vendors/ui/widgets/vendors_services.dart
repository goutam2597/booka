
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/features/home/ui/widgets/service_card_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

/// Services scroller
class VendorsServices extends StatelessWidget {
  final List<ServicesModel> services;
  const VendorsServices({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No services found'.tr,
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey.shade700),
        ),
      );
    }

    return SizedBox(
      height: 346,
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: services.length,
          itemBuilder: (context, index) {
            final item = services[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 900),
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 16 : 8,
                      right: index == services.length - 1 ? 16 : 0,
                    ),
                    child: SizedBox(
                      width: 320,
                      child: ServiceCardWidget(item: item),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}