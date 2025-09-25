import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/wishlist/data/models/wishlist_model.dart';
import 'package:bookapp_customer/features/wishlist/providers/wishlist_provider.dart';
import 'package:bookapp_customer/features/wishlist/providers/wishlist_ui_provider.dart';
import 'package:bookapp_customer/features/wishlist/ui/widgets/wishlist_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  final int userId;
  const WishlistScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final ui = context.watch<WishlistUiProvider>();

    final List<WishlistModel> wishlistItems = (() {
      final q = ui.query.trim().toLowerCase();
      if (q.isEmpty) return List<WishlistModel>.from(wishlist.items);
      return wishlist.items.where((w) {
        final name = (w.name).toLowerCase();
        final averageRating = (w.averageRating);
        return name.contains(q) || averageRating.toString().contains(q);
      }).toList();
    })();

    return Scaffold(
      body: Builder(
        builder: (pageContext) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(title: wishlist.pageTitle),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: ui.searchController,
                onChanged: ui.setQuery,
                decoration: InputDecoration(
                  hintText: 'Search Service'.tr,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(AssetsPath.searchIconSvg),
                  ),
                  suffixIcon: (ui.query.isEmpty)
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          onPressed: ui.clear,
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),

            if (wishlist.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: (ui.query.trim().isEmpty)
                    ? CustomHeaderTextWidget(
                        text:
                            '${'Total Wishlists'.tr} '
                            ':'
                            ' (${wishlist.items.length})',
                      )
                    : CustomHeaderTextWidget(
                        text:
                            'Showing ${wishlistItems.length} of ${wishlist.items.length}',
                      ),
              ),

            Expanded(
              child: () {
                if (wishlist.status == WishlistStatus.loading) {
                  return const Center(child: CustomCPI());
                }

                if (wishlist.items.isEmpty) {
                  return Center(child: Text('NO WISHLISTS FOUND'.tr));
                }

                return RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: AppColors.primaryColor,
                  onRefresh: wishlist.refresh,
                  child: (wishlistItems.isEmpty)
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: const [
                            SizedBox(height: 48),
                            Center(child: Text('No matches found.')),
                            SizedBox(height: 400),
                          ],
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: wishlistItems.length,
                          itemBuilder: (context, index) {
                            final item = wishlistItems[index];
                            return WishlistCard(
                              wishlistData: item,
                              scaffoldContext: pageContext,
                            );
                          },
                        ),
                );
              }(),
            ),
          ],
        ),
      ),
    );
  }
}
