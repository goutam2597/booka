import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomStepper extends StatelessWidget {
  final int activeStep;

  const CustomStepper({super.key, required this.activeStep});

  static const double _circleDiameter = 36.0;
  static const double _lineWidth = 5.0;
  static const double _linePadding = _circleDiameter / 0.6;
  static const Duration _animationDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    final List<Map<String, dynamic>> steps = [
      {'label': 'Staff', 'isCompleted': activeStep > 1},
      {'label': 'Date & Time', 'isCompleted': activeStep > 2},
      {'label': 'Information', 'isCompleted': activeStep > 3},
      {'label': 'Summary', 'isCompleted': activeStep > 4},
      {'label': 'Payment', 'isCompleted': activeStep > 5},
    ];

    final height = isRtl ? 64.00 : 60.00;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Grey background line
          Positioned(
            top: _circleDiameter / 2 - _lineWidth / 2,
            left: isRtl ? 50 : _linePadding,
            right: isRtl ? _linePadding : 50,
            child: Container(height: _lineWidth, color: Colors.grey.shade300),
          ),

          // Animated progress line
          Positioned(
            top: _circleDiameter / 2 - _lineWidth / 2,
            left: isRtl ? 50 : _linePadding,
            right: isRtl ? _linePadding : 50,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final stepCount = steps.length;
                final progress = (activeStep - 1) / (stepCount - 1);

                return Align(
                  alignment: isRtl
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: progress),
                    duration: _animationDuration,
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, _) {
                      return Container(
                        width: totalWidth * value,
                        height: _lineWidth,
                        color: AppColors.primaryColor,
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Steps row
          Row(
            children: steps.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> step = entry.value;
              return Expanded(
                child: _buildStep(
                  label: step['label'] as String,
                  isCompleted: step['isCompleted'] as bool,
                  isActive: activeStep == index + 1,
                  number: '${index + 1}',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Step circle and label with animation
  Widget _buildStep({
    required String label,
    required bool isCompleted,
    required bool isActive,
    required String number,
  }) {
    final Color circleColor = isCompleted ? AppColors.primaryColor : Colors.white;
    final Color borderColor = (isCompleted || isActive)
        ? AppColors.primaryColor
        : Colors.grey;
    final Color labelColor = isActive ? AppColors.primaryColor : Colors.black54;
    final FontWeight labelWeight = isActive
        ? FontWeight.bold
        : FontWeight.normal;

    final Widget child = (isCompleted)
        ? const Icon(Icons.check, color: Colors.white, size: 20)
        : Text(
            number.tr,
            style: TextStyle(
              color: isActive ? AppColors.primaryColor : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          width: _circleDiameter,
          height: _circleDiameter,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: child,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: labelColor,
            fontWeight: labelWeight,
            fontSize: 12,
          ),
          child: Text(label.tr, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
