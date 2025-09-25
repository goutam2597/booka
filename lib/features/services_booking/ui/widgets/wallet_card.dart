import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class WalletCard extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback? onTap;
  const WalletCard({
    super.key,
    required this.asset,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              SvgPicture.asset(asset, height: 48, width: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label.tr,
                  style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.colorText),
            ],
          ),
        ),
      ),
    );
  }
}
