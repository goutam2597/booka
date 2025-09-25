import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:bookapp_customer/features/services/providers/service_details_provider.dart';
import 'package:bookapp_customer/features/services/providers/service_reviews_ui_provider.dart';
import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/adress_map.dart';
import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/review_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_html/flutter_html.dart' hide Marker;
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CustomTabBarWidget extends StatefulWidget {
  final ServiceDetailsModel tabDetails;
  const CustomTabBarWidget({super.key, required this.tabDetails});

  @override
  State<CustomTabBarWidget> createState() => _CustomTabBarWidgetState();
}

class _CustomTabBarWidgetState extends State<CustomTabBarWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _contactRow(IconData icon, String? text) =>
      (text == null || text.isEmpty)
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryColor),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  text.tr,
                  style: AppTextStyles.bodyLargeGrey.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        );

  Widget _featuresList(String features) {
    final list = features
        .split(RegExp(r'\r\n|\n'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (list.isEmpty) {
      return Text('No features listed.', style: AppTextStyles.bodyLargeGrey);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f.tr,
                      style: AppTextStyles.bodyLargeGrey.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _starPicker(ServiceReviewsUiProvider p) => Row(
    children: List.generate(5, (i) {
      final idx = i + 1, selected = p.rating >= idx;
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        icon: Icon(
          selected ? Icons.star : Icons.star_border,
          color: Colors.orange,
        ),
        onPressed: p.submitting ? null : () => p.setRating(idx),
      );
    }),
  );

  Widget _ratingStars(String? s) {
    final r = int.tryParse(s ?? '') ?? 0;
    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1;
        return Icon(
          idx <= r ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.orange,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceReviewsUiProvider(),
      builder: (context, _) {
        final reviewsUi = context.watch<ServiceReviewsUiProvider>();
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              splashFactory: NoSplash.splashFactory,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 5, color: AppColors.primaryColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              tabs: [
                Tab(text: 'Description'.tr),
                Tab(text: 'Business Days'.tr),
                Tab(text: 'Features'.tr),
                Tab(text: 'Address'.tr),
                Tab(text: 'Reviews'.tr),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _tabController.animation ?? _tabController,
              builder: (_, _) {
                final i = _tabController.index;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildTabBody(
                    context: context,
                    index: i,
                    key: ValueKey(i),
                    reviewsProvider: reviewsUi,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBody({
    required BuildContext context,
    required int index,
    required ServiceReviewsUiProvider reviewsProvider,
    Key? key,
  }) {
    final d = widget.tabDetails;
    switch (index) {
      case 0:
        return Html(
          key: key,
          data: d.details.content.description,
          style: {
            'body': Style.fromTextStyle(
              AppTextStyles.bodyLargeGrey.copyWith(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ).copyWith(margin: Margins.zero, padding: HtmlPaddings.zero),
          },
        );

      case 1:
        return Column(
          children: [
            Row(
              key: key,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: d.allDays
                        .map(
                          (e) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: SizedBox(),
                          ),
                        )
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              d.allDays[entry.key].day.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: d.allDays
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              "${e.minTime} - ${e.maxTime}",
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            if (d.allDays.isEmpty)
              SizedBox(
                height: 150,
                child: Center(child: Text('No business days listed')),
              ),
          ],
        );

      case 2:
        return Container(
          key: key,
          alignment: Alignment.topLeft,
          child: _featuresList(d.details.content.features),
        );

      case 3:
        final lat = double.tryParse(d.details.lat ?? '') ?? 0.0,
            lon = double.tryParse(d.details.lon ?? '') ?? 0.0;
        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our Address'.tr, style: AppTextStyles.headingMedium),
            const SizedBox(height: 4),
            _contactRow(
              FontAwesomeIcons.locationDot,
              d.details.content.address,
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: SizedBox(
                height: 240,
                child: KeylessLocationMapWithUser(lat: lat, lon: lon),
              ),
            ),
          ],
        );

      case 4:
        final reviews = <Review>[...d.details.reviews, ...d.reviews]
          ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
        final Map<int, int> starCounts = {for (var i = 1; i <= 5; i++) i: 0};
        for (final r in reviews) {
          final star = int.tryParse((r.rating ?? '').trim());
          if (star != null && star >= 1 && star <= 5) {
            starCounts[star] = (starCounts[star] ?? 0) + 1;
          }
        }
        final double average =
            double.tryParse(d.details.averageRating ?? '') ??
            (reviews.isEmpty
                ? 0.0
                : reviews.fold<double>(
                        0.0,
                        (sum, r) =>
                            sum + (double.tryParse(r.rating ?? '0') ?? 0.0),
                      ) /
                      reviews.length);

        return Column(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewBreakdown(
              data: [
                for (var s = 5; s >= 1; s--)
                  ReviewBreakdownData(s, starCounts[s] ?? 0),
              ],
              totalReviews: reviews.length,
              averageRating: average,
            ),
            const SizedBox(height: 16),
            Text('All Reviews'.tr, style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            if (reviews.isEmpty)
              Text(
                'This service has no review yet'.tr,
                style: AppTextStyles.bodyLargeGrey.copyWith(
                  color: Colors.grey.shade600,
                ),
              )
            else
              Column(
                children: [
                  for (final r in reviews)
                    _ReviewLine(review: r, ratingStars: _ratingStars(r.rating)),
                ],
              ),
            const SizedBox(height: 16),
            Text('Add Review'.tr, style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: reviewsProvider.commentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    enabled: !reviewsProvider.submitting,
                  ),
                  const SizedBox(height: 8),
                  Text('Rating'.tr, style: AppTextStyles.bodyLarge),
                  _starPicker(reviewsProvider),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: CustomButtonWidget(
                      onPressed: () {
                        reviewsProvider.submitting
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                await reviewsProvider.submit(
                                  details: d,
                                  dataProvider: context
                                      .read<ServiceDetailsProvider>(),
                                );
                                if (!context.mounted) return;
                                CustomSnackBar.show(
                                  context,
                                  reviewsProvider.response ?? 'Done',
                                  title:
                                      (reviewsProvider.response ?? '')
                                          .toLowerCase()
                                          .contains('fail')
                                      ? 'Error'
                                      : 'Success',
                                );
                              };
                      },
                      text: '',
                      child: reviewsProvider.submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (reviewsProvider.response != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      reviewsProvider.response!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _ReviewLine extends StatelessWidget {
  final Review review;
  final Widget ratingStars;
  const _ReviewLine({required this.review, required this.ratingStars});
  @override
  Widget build(BuildContext context) => ReviewTile(
    createdAtIso: review.createdAt,
    ratingStars: ratingStars,
    review: review,
  );
}
