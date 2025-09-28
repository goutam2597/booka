import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/services/providers/services_provider.dart';
import 'package:bookapp_customer/features/home/providers/home_provider.dart';
import 'package:bookapp_customer/features/home/data/models/home_models.dart';
import 'package:bookapp_customer/features/common/providers/nav_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenHeaderWidget extends StatefulWidget {
  const HomeScreenHeaderWidget({super.key});

  @override
  State<HomeScreenHeaderWidget> createState() => _HomeScreenHeaderWidgetState();
}

class _HomeScreenHeaderWidgetState extends State<HomeScreenHeaderWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String raw) async {
    final q = raw.trim();
    if (q.isEmpty) return;

    final provider = context.read<ServicesProvider>();
    await provider.init();
    if (!mounted) return;
    provider.search(q);
    FocusScope.of(context).unfocus();
    context.read<NavProvider>().setIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [_buildHeaderBackground(), _buildSearchBar()],
    );
  }

  Widget _buildHeaderBackground() {
    final sections = context.select<HomeProvider, SectionContent?>(
      (p) => p.sections,
    );
    final bg = (sections?.heroBackgroundImg ?? '').trim();
    const imageHeight = 180.0;

    final isNet =
        bg.isNotEmpty &&
        (bg.startsWith('http://') || bg.startsWith('https://'));

    if (!isNet) {
      return Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage(AssetsPath.topBGPng),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildHeaderContent(sections),
      );
    }

    return CachedNetworkImage(
      imageUrl: bg,
      imageBuilder: (context, imageProvider) => Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
        child: _buildHeaderContent(sections),
      ),
      placeholder: (context, url) => _ShimmerBox(height: imageHeight),
      errorWidget: (context, url, error) => Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(
            image: AssetImage(AssetsPath.topBGPng),
            fit: BoxFit.cover,
          ),
        ),
        child: _buildHeaderContent(sections),
      ),
      filterQuality: FilterQuality.low,
    );
  }

  Widget _buildHeaderContent(SectionContent? sections) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTag(sections),
                const SizedBox(height: 16),
                Text(
                  sections?.heroSubtitle ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sections?.heroText ?? 'BookApp Platform',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text('')),
        ],
      ),
    );
  }

  Widget _buildTag(SectionContent? sections) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(99),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Text(
        sections?.heroTitle ?? '',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    final borderRadius = BorderRadius.circular(12);
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade100, width: 1.5),
      borderRadius: borderRadius,
    );

    return Positioned(
      bottom: -24,
      left: 8,
      right: 8,
      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: borderRadius,
        child: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: SvgPicture.asset(
                AssetsPath.searchIconSvg,
                width: 24,
                height: 24,
              ),
              onPressed: () => _performSearch(_controller.text),
              tooltip: 'Search',
            ),
            hintText: 'Search Service'.tr,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
