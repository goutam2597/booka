import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton grid used during initial loading.
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({super.key,
    required this.itemWidth,
    required this.crossAxisCount,
    required this.spacing,
  });

  final double itemWidth;
  final int crossAxisCount;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final count = (crossAxisCount * 16).clamp(8, 12);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 1200),
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(count, (index) {
            return SizedBox(width: itemWidth, child: const _SkeletonCard());
          }),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 14,
            width: double.infinity,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: double.infinity,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 12),
          Container(
            height: 32,
            width: double.infinity,
            color: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}