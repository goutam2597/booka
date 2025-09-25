
import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:bookapp_customer/features/common/providers/nav_provider.dart';
import 'package:bookapp_customer/features/home/providers/home_provider.dart';
import 'package:bookapp_customer/features/home/ui/widgets/service_card_widget.dart';
import 'package:bookapp_customer/features/home/ui/widgets/text_n_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class FeaturedServices extends StatelessWidget {
  const FeaturedServices({
    super.key,
    required this.padding,
    required this.height,
    required this.context,
    required this.services,
  });

  final double padding;
  final double height;
  final BuildContext context;
  final List services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No featured services available")),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
          child: TextNButtonWidget(
            title:
            context
                .read<HomeProvider>()
                .sections
                ?.featuredServiceSectionTitle ??
                'Featured Services',
            onTap: () {
              try {
                context.read<NavProvider>().setIndex(1);
              } catch (_) {
                Get.toNamed(AppRoutes.bottomNav, arguments: 1);
              }
            },
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
                child: SizedBox(
                  width: 320,
                  child: ServiceCardWidget(item: services[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
