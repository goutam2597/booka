import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/details_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import '../../widgets/star_rating_widget.dart';

class DetailsLoadingPrefill extends StatelessWidget {
  const DetailsLoadingPrefill({super.key, required this.prefill});
  final ServicesModel prefill;

  @override
  Widget build(BuildContext context) {
    final p = prefill;
    return Scaffold(
      appBar: const DetailsAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                p.categoryName,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              const RatingStarsWidget(
                showReviews: false,
                reviews: '',
                rating: '0.0',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.name,
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.colorText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.address ?? 'Address not available',
            style: AppTextStyles.bodyLargeGrey.copyWith(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                p.price,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              if (p.previousPrice != null)
                Text(
                  "\$${p.previousPrice}",
                  style: AppTextStyles.headingMedium.copyWith(
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          const Center(child: CustomCPI()),
        ],
      ),
    );
  }
}
