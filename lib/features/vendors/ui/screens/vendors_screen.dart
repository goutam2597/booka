import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/vendors/ui/widgets/vendors_card_widget.dart';
import 'package:bookapp_customer/features/vendors/providers/vendors_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class VendorsScreen extends StatelessWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 16 * 2 - 8) / 2;

    return Scaffold(
      body: Consumer<VendorsListProvider>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Center(child: CustomCPI());
          }
          if (vm.error != null) {
            return Center(child: Text(vm.error!));
          }
          final vendors = vm.filtered;
          if (vendors.isEmpty) {
            return const Center(child: Text('No vendors found.'));
          }
          return Column(
            children: [
              const CustomAppBar(title: 'Vendors'),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            TextField(
                              onChanged: (value) =>
                                  vm.setQuery(value.toLowerCase()),
                              decoration: InputDecoration(
                                hintText: 'Vendor name/username'.tr,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    AssetsPath.searchIconSvg,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            CustomHeaderTextWidget(
                              text:
                                  '${vendors.length} ${'Vendor Profile Available'.tr}',
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: AnimationLimiter(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(vendors.length, (index) {
                              final vendor = vendors[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: ScaleAnimation(
                                  scale: 0.8,
                                  child: FadeInAnimation(
                                    child: SizedBox(
                                      width: itemWidth,
                                      child: FittedBox(
                                        child: VendorsCardWidget(
                                          showVisitStore: false,
                                          showRating: true,
                                          vendor: vendor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
