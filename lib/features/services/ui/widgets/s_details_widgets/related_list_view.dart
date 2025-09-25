import 'package:flutter/material.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/home/ui/widgets/service_card_widget.dart';

class RelatedListView extends StatelessWidget {
  const RelatedListView({super.key, required this.services});
  final List<ServicesModel> services;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: services.length,
        itemExtent: 336, // fixed card width (320) + horizontal padding (16)
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: SizedBox(
              width: 320,
              child: ServiceCardWidget(item: services[index]),
            ),
          );
        },
      ),
    );
  }
}
