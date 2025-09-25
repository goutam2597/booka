import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_colors.dart';

class CategoryFilterChips extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry padding;
  final double height;
  final double spacing;
  final bool shrinkWrap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double fontSize;
  final FontWeight fontWeight;
  final BorderRadiusGeometry borderRadius;

  const CategoryFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.height = 44,
    this.spacing = 8,
    this.shrinkWrap = false,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final selColor = selectedColor ?? AppColors.primaryColor;
    final unselColor = unselectedColor ?? Colors.white;
    final selText = selectedTextColor ?? Colors.white;
    final unselText = unselectedTextColor ?? Colors.black87;

    return SizedBox(
      height: height,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: padding,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: shrinkWrap,
        itemCount: labels.length,
        separatorBuilder: (_, _) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final bg = isSelected ? selColor : unselColor;
          final textColor = isSelected ? selText : unselText;

          final chip = AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: borderRadius,
              border: Border.all(
                color: isSelected ? selColor : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selColor.withAlpha(25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
            ),
          );

          return GestureDetector(onTap: () => onSelected(index), child: chip);
        },
      ),
    );
  }
}
