import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/services/data/models/services_filter.dart';
import 'package:bookapp_customer/features/services/providers/services_provider.dart';
import 'package:bookapp_customer/features/services/ui/widgets/all_services_widgets/search_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CustomSearchBarWidget extends StatefulWidget {
  final bool showFilter;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilterTap;
  final BorderRadius borderRadius;
  final String hintText;

  const CustomSearchBarWidget({
    super.key,
    this.showFilter = true,
    this.onChanged,
    this.onFilterTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.hintText = 'Search Services',
    this.onSearch,
  });

  @override
  State<CustomSearchBarWidget> createState() => _CustomSearchBarWidgetState();
}

class _CustomSearchBarWidgetState extends State<CustomSearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(BuildContext context, String value) {
    final q = value.trim();

    if (widget.onSearch != null) {
      widget.onSearch!(q);
    } else {
      context.read<ServicesProvider>().search(q);
    }
  }

  void _clearSearch(BuildContext context) {
    _controller.clear();
    if (widget.onSearch != null || widget.onChanged != null) {
      widget.onChanged?.call('');
      widget.onSearch?.call('');
    } else {
      context.read<ServicesProvider>().clearSearch();
    }
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicesProvider>();

    if (_controller.text != provider.query) {
      _controller.value = _controller.value.copyWith(
        text: provider.query,
        selection: TextSelection.collapsed(offset: provider.query.length),
        composing: TextRange.empty,
      );
    }

    final hasActiveSearch = provider.query.trim().isNotEmpty;

    return Material(
      elevation: 0.3,
      borderRadius: widget.borderRadius,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
          borderRadius: widget.borderRadius,
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            SvgPicture.asset(AssetsPath.searchIconSvg, width: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                onSubmitted: (v) => _handleSubmitted(context, v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: widget.hintText.tr,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (widget.showFilter) ...[
              const SizedBox(width: 8),

              hasActiveSearch
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Clear search'.tr,
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                      onPressed: () => _clearSearch(context),
                    )
                  : IconButton(
                      padding: EdgeInsets.zero,
                      icon: SvgPicture.asset(AssetsPath.filterSvg, width: 20),
                      onPressed: () => _openFilters(context, provider),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openFilters(
    BuildContext context,
    ServicesProvider provider,
  ) async {
    await provider.init();

    if (!context.mounted) return;
    final result = await showDialog<ServicesFilter>(
      context: context,
      builder: (_) => SearchFilterWidget(
        initial: provider.filter,
        categories: provider.allCategoryNames,
        ratings: const ['All', '5', '4', '3', '2', '1'],
      ),
    );

    if (result != null) {
      final normalized = ServicesFilter(
        category: (result.category == 'All') ? null : result.category,
        minRating: result.minRating,
        minPrice: result.minPrice,
        maxPrice: result.maxPrice,
        sort: result.sort,
      );
      provider.applyFilter(normalized);
    }
  }
}
