import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';
import 'package:bookapp_customer/features/vendors/ui/widgets/vendors_card_widget.dart';
import 'package:bookapp_customer/network_service/core/vendor_network_service.dart';
import 'package:flutter/material.dart';

class HomeVendorCardListView extends StatelessWidget {
  final List<VendorModel>? vendors;
  const HomeVendorCardListView({super.key, this.vendors});

  @override
  Widget build(BuildContext context) {
    if (vendors != null && vendors!.isNotEmpty) {
      final v = vendors!;
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: v.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => VendorsCardWidget(
          vendor: v[index],
          showRating: true,
          showVisitStore: false,
        ),
      );
    }
    return SizedBox(
      child: FutureBuilder<List<VendorModel>>(
        future: VendorNetworkService.getVendorList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vendors found.'));
          }
          final vendors = snapshot.data!;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vendors.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final vendor = vendors[index];

              return VendorsCardWidget(
                vendor: vendor,
                showRating: true,
                showVisitStore: false,
              );
            },
          );
        },
      ),
    );
  }
}
