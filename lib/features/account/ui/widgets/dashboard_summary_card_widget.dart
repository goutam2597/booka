import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardSummaryCardWidget extends StatelessWidget {
  final String qty;
  final String iconSvg;
  final String cardTitle;
  final VoidCallback onTap;
  final double fontSize;

  const DashboardSummaryCardWidget({
    super.key,
    required this.qty,
    required this.iconSvg,
    required this.cardTitle,
    required this.onTap,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage(AssetsPath.bgCardPng),
              fit: BoxFit.cover,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown, // Will scale down content if needed
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───── Icon + Quantity Row ─────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 56,
                        width: 56,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: SvgPicture.asset(
                          iconSvg,
                          colorFilter:  ColorFilter.mode(
                            AppColors.primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        qty,
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ───── Title Text ─────
                  Text(
                    cardTitle,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
