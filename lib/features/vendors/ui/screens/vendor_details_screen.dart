import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';
import 'package:bookapp_customer/features/common/ui/widgets/category_filter_chips.dart';
import 'package:bookapp_customer/features/vendors/providers/vendor_details_provider.dart';
import 'package:bookapp_customer/features/vendors/providers/vendor_details_ui_provider.dart';
import 'package:bookapp_customer/features/vendors/ui/widgets/vendor_details_card.dart';
import 'package:bookapp_customer/features/vendors/ui/widgets/vendors_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class VendorDetailsScreen extends StatefulWidget {
  final String username;
  const VendorDetailsScreen({super.key, required this.username});

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  late final VendorDetailsProvider _dataProvider;
  late final VendorDetailsUiProvider _uiProvider;

  @override
  void initState() {
    super.initState();
    _dataProvider = VendorDetailsProvider();
    _uiProvider = VendorDetailsUiProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _dataProvider.stateFor(widget.username);
      if (state.data == null && !state.loading) {
        _dataProvider.fetch(widget.username);
      }
    });
  }

  @override
  void dispose() {
    _dataProvider.dispose();
    _uiProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VendorDetailsUiProvider>.value(
          value: _uiProvider,
        ),
        ChangeNotifierProvider<VendorDetailsProvider>.value(
          value: _dataProvider,
        ),
      ],
      builder: (context, _) {
        final dataProvider = context.watch<VendorDetailsProvider>();
        final ui = context.watch<VendorDetailsUiProvider>();
        final s = dataProvider.stateFor(widget.username);

        // Loading (with no cached data)
        if (s.loading && s.data == null) {
          return const Scaffold(
            body: Column(
              children: [
                CustomAppBar(title: 'Vendor Details'),
                Expanded(child: Center(child: CustomCPI())),
              ],
            ),
          );
        }

        if (s.error != null && s.data == null) {
          return Scaffold(
            body: Column(
              children: [
                const CustomAppBar(title: 'Vendor Details'),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 36),
                          const SizedBox(height: 8),
                          Text(s.error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => dataProvider.fetch(
                              widget.username,
                              forceRefresh: true,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Still no data (unexpected empty) — guard to avoid cast crashes
        if (s.data == null) {
          return Scaffold(
            body: Column(
              children: [
                const CustomAppBar(title: 'Vendor Details'),
                Expanded(
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => dataProvider.fetch(
                        widget.username,
                        forceRefresh: true,
                      ),
                      child: const Text('Load Details'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final VendorDetailsModel details = s.data!;
        if (!ui.didHydrate) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            final uip = context.read<VendorDetailsUiProvider>();
            if (!uip.didHydrate) {
              uip.hydrateFrom(details);
            }
          });
        }
        final cats = ui.categories;
        final int sel = ui.selectedCategoryIndex;
        final List<ServicesModel> visibleServices = (sel == 0)
            ? details.services
            : details.services
                  .where((srv) => srv.categoryName == cats[sel])
                  .toList();

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const CustomAppBar(title: 'Vendor Details'),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: CustomHeaderTextWidget(
                                  text: 'Services Available',
                                ),
                              ),
                              const SizedBox(height: 16),
                              CategoryFilterChips(
                                labels: cats,
                                selectedIndex: sel,
                                onSelected: ui.setSelected,
                              ),
                              const SizedBox(height: 16),
                              VendorsServices(services: visibleServices),
                              const SizedBox(height: 24),
                              VendorDetailsCard(details: details),
                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Replaced legacy CategoryChips with reusable CategoryFilterChips.

class ColumnText extends StatelessWidget {
  final List<String> items;
  final bool isLabel;
  const ColumnText({super.key, required this.items, this.isLabel = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                item.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isLabel ? const TextStyle(fontSize: 14) : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
