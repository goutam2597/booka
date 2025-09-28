import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ReviewTile extends StatelessWidget {
  final String? createdAtIso;
  final Widget ratingStars;
  final Review review;

  const ReviewTile({
    super.key,
    required this.createdAtIso,
    required this.ratingStars,
    required this.review,
  });

  String timeAgoFromIso(String? iso, {DateTime? now}) {
    if (iso == null || iso.isEmpty) return '';

    String s = iso.trim();

    final hasZone =
        s.endsWith('Z') ||
        s.contains('+') ||
        (s.contains('-') && s.contains('T'));
    if (!hasZone) {
      s = '${s}Z';
    }

    DateTime dt;
    try {
      dt = DateTime.parse(s);
    } catch (_) {
      return iso; // fallback to original string
    }

    final currentUtc = (now ?? DateTime.now()).toUtc();
    final eventUtc = dt.toUtc();

    var diff = currentUtc.difference(eventUtc);
    if (diff.isNegative) diff = Duration.zero;

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final weeks = (diff.inDays / 7).floor();
    if (diff.inDays < 30) return '${weeks}w ago';

    final months = (diff.inDays / 30).floor();
    if (diff.inDays < 365) return '${months}mo ago';

    final years = (diff.inDays / 365).floor();
    return '${years}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _UserAvatar(review.user?.image),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              review.user?.name ?? 'Unknown',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if ((createdAtIso ?? '').isNotEmpty)
                            Text(
                              timeAgoFromIso(createdAtIso),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ratingStars,
                          const SizedBox(width: 6),
                          Text(
                            '(${review.rating ?? ''})',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Verified User', style: AppTextStyles.bodySmall),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Visibility(
              visible: review.comment != 'null' && review.comment.isNotEmpty,
              replacement: Text('No comments!', style: AppTextStyles.bodySmall),
              child: Text(review.comment, style: AppTextStyles.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? url;
  const _UserAvatar(this.url);

  bool get _isNetwork =>
      (url != null && url!.isNotEmpty && !url!.startsWith('assets/'));

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        placeholder: (context, u) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, u, e) =>
            Image.asset(AssetsPath.userPlaceholderPng, fit: BoxFit.cover),
      );
    }
    return Image.asset(AssetsPath.userPlaceholderPng, fit: BoxFit.cover);
  }
}

class ReviewBreakdownData {
  final int star;
  final int count;
  const ReviewBreakdownData(this.star, this.count);
}

class ReviewBreakdown extends StatelessWidget {
  final List<ReviewBreakdownData> data;
  final int totalReviews;
  final double averageRating;

  final Color? primaryColor;
  final Color? trackColor;
  final double barHeight;
  final double radius;
  final EdgeInsets padding;

  const ReviewBreakdown({
    super.key,
    required this.data,
    required this.totalReviews,
    required this.averageRating,
    this.primaryColor,
    this.trackColor,
    this.barHeight = 10,
    this.radius = 12,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final track = trackColor ?? Colors.grey.shade200;

    final map = {for (var d in data) d.star: d.count};
    int countFor(int s) => map[s] ?? 0;

    double widthFactor(int star) => star / 5.0;

    return Card(
      color: Colors.white,
      elevation: 0.3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                Text(
                  '${'Total Reviews'.tr} : $totalReviews',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    StarRow(rating: averageRating),
                    const SizedBox(width: 6),
                    Text(
                      '(${averageRating.toStringAsFixed(1)})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            for (int s = 5; s >= 1; s--) ...[
              _BarRow(
                label: '$s Stars'.tr,
                value: countFor(s) > 0 ? widthFactor(s) : 0, // fixed %
                barHeight: barHeight,
                radius: radius,
                fillColor: AppColors.primaryColor,
                trackColor: track,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final double barHeight;
  final double radius;
  final Color fillColor;
  final Color trackColor;

  const _BarRow({
    required this.label,
    required this.value,
    required this.barHeight,
    required this.radius,
    required this.fillColor,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Row(
      children: [
        SizedBox(width: 64, child: Text(label, style: textStyle)),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth * value.clamp(0.0, 1.0);
              return Stack(
                children: [
                  // track
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(barHeight / 2),
                    ),
                  ),
                  // fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    width: width,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(barHeight / 2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class StarRow extends StatelessWidget {
  final double rating;
  const StarRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5 && full < 5;
    final color = Colors.orange;

    return Row(
      children: List.generate(5, (i) {
        IconData icon;
        if (i < full) {
          icon = Icons.star;
        } else if (i == full && hasHalf) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: 18, color: color);
      }),
    );
  }
}
