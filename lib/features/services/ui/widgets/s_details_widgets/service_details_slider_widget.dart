import 'package:bookapp_customer/app/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imgList;
  final ValueNotifier<int> selectedIndex;

  const ImageCarousel({
    super.key,
    required this.imgList,
    required this.selectedIndex,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final CarouselSliderController _carouselController;

  bool _attached = false; // simple guard during first frame / hot reloads

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    // after first frame, the controller should be attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _attached = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final imgList = widget.imgList;

    return SizedBox(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ───── Carousel Images ─────
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              autoPlay: true,
              height: 350.0,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) =>
                  widget.selectedIndex.value = index,
            ),
            items: imgList.map((imgPath) {
              final w = MediaQuery.of(context).size.width;
              return SizedBox(
                width: w,
                height: 350,
                child: _networkImageWithShimmer(
                  imgPath,
                  width: w,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),

          // ───── Image Thumbnails ─────
          if (imgList.isNotEmpty)
            Positioned(
              bottom: 40,
              child: ValueListenableBuilder<int>(
                valueListenable: widget.selectedIndex,
                builder: (_, value, _) => Row(
                  children: List.generate(imgList.length, (index) {
                    final isSelected = value == index;
                    return GestureDetector(
                      onTap: () {
                        if (!_attached) {
                          return; // guard against null state after reload
                        }
                        _carouselController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 56,
                        width: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: _networkImageWithShimmer(
                          imgList[index],
                          width: 72,
                          height: 56,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // ───── Dots Page Indicator ─────
          Positioned(
            bottom: 16,
            child: ValueListenableBuilder<int>(
              valueListenable: widget.selectedIndex,
              builder: (_, value, _) => Row(
                children: List.generate(imgList.length, (index) {
                  final isSelected = value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 10,
                    width: isSelected ? 24 : 10,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper shimmer placeholder
Widget _shimmerBox({double? width, double? height, BorderRadius? radius}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
    ),
  );
}

/// CachedNetworkImage wrapper with shimmer + error fallback
Widget _networkImageWithShimmer(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  Widget? error,
}) {
  final br = borderRadius ?? BorderRadius.zero;
  return ClipRRect(
    borderRadius: br,
    child: CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) =>
          _shimmerBox(width: width, height: height, radius: br),
      errorWidget: (context, _, _) =>
          error ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image),
          ),
    ),
  );
}
