import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:bookapp_customer/features/common/ui/widgets/category_filter_chips.dart';
import 'package:bookapp_customer/features/services/providers/services_provider.dart';
import 'package:bookapp_customer/features/home/ui/widgets/featured_services.dart';
import 'package:bookapp_customer/features/home/ui/widgets/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/home/providers/notification_provider.dart';
import 'package:bookapp_customer/features/home/providers/home_provider.dart';
import 'package:bookapp_customer/features/home/ui/widgets/category_list_widget.dart';
import 'package:bookapp_customer/features/home/ui/widgets/home_screen_header_widget.dart';
import 'package:bookapp_customer/features/home/ui/widgets/home_vendor_list_view.dart';
import 'package:bookapp_customer/features/home/ui/widgets/service_card_widget.dart';
import 'package:bookapp_customer/features/home/ui/widgets/text_n_button_widget.dart';
import 'package:bookapp_customer/features/services/ui/widgets/all_services_widgets/search_filter_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_filter.dart';
import 'package:bookapp_customer/features/common/providers/nav_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationProvider, bool>(
      (p) => p.hasUnread,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final horizontalPadding = isTablet ? 24.0 : 16.0;
        final sectionHeight = isTablet ? 380.0 : 346.0;
        final categoryHeight = isTablet ? 130.0 : 100.0;
        final vendorHeight = isTablet ? 340.0 : 300.0;
        final logoWidth = isTablet ? 150.0 : 125.0;

        return Scaffold(
          appBar: HomeAppBar(
            mounted: mounted,
            context: context,
            logoWidth: logoWidth,
            hasUnread: hasUnread,
          ),
          body: Consumer<HomeProvider>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const Center(child: CustomCPI());
              }
              if (vm.error != null) {
                return Center(child: Text(vm.error!));
              }
              if (vm.services.isEmpty && vm.featuredServices.isEmpty) {
                return const Center(child: Text('No Data Found'));
              }

              final allCategoryNames = [
                'All',
                ...vm.categories.map((c) => c.name),
              ];

              final selectedIdxFromVm = allCategoryNames.indexOf(
                vm.selectedCategory,
              );
              final selectedIndex = selectedIdxFromVm == -1
                  ? 0
                  : selectedIdxFromVm;

              return RefreshIndicator(
                color: AppColors.primaryColor,
                backgroundColor: Colors.white,
                onRefresh: vm.refresh,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    //----------Home Screen Header ---------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: const HomeScreenHeaderWidget(),
                      ),
                    ),
                    //----------Service Categories (grid/cards) ---------
                    SliverToBoxAdapter(
                      child: _buildServiceCategory(
                        horizontalPadding,
                        categoryHeight,
                        vm,
                      ),
                    ),
                    //----------Featured Services ---------
                    SliverToBoxAdapter(
                      child: FeaturedServices(
                        padding: horizontalPadding,
                        height: sectionHeight,
                        context: context,
                        services: vm.featuredServices,
                      ),
                    ),
                    //----------Top Featured Vendors ---------
                    SliverToBoxAdapter(
                      child: _buildTopFeaturedVendors(
                        context,
                        horizontalPadding,
                        vendorHeight,
                        vendors: vm.featuredVendors,
                      ),
                    ),
                    //----------Popular Services Header ---------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ),
                        child: TextNButtonWidget(
                          title:
                              context
                                  .read<HomeProvider>()
                                  .sections
                                  ?.latestServiceSectionTitle ??
                              'Latest Services',
                          onTap: () => context.read<NavProvider>().setIndex(1),
                        ),
                      ),
                    ),

                    //----------Category Filter Chips (same visual as original)---------
                    SliverToBoxAdapter(
                      child: CategoryFilterChips(
                        labels: allCategoryNames,
                        selectedIndex: selectedIndex,
                        onSelected: (i) {
                          if (i >= 0 && i < allCategoryNames.length) {
                            vm.selectCategory(allCategoryNames[i]);
                          }
                        },
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                      ),
                    ),

                    //----------Popular Services List ---------
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: sectionHeight,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: vm.popularServices.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 16 : 8,
                                right: 8,
                              ),
                              child: SizedBox(
                                width: 320,
                                child: ServiceCardWidget(
                                  item: vm.popularServices[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  //---------- Service Categories Section ---------
  Widget _buildServiceCategory(double padding, double height, HomeProvider vm) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          child: TextNButtonWidget(
            title: vm.sections?.categorySectionTitle ?? 'Categories'.tr,
            actionText: 'Filter',
            icon: FontAwesomeIcons.sliders,
            size: 14,
            onTap: () async {
              final sp = context.read<ServicesProvider>();
              await sp.init();
              if (!context.mounted) return;

              final result = await showDialog<ServicesFilter>(
                context: context,
                builder: (_) => SearchFilterWidget(
                  initial: sp.filter,
                  categories: sp.allCategoryNames,
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
                sp.applyFilter(normalized);
                // Navigate to Services only when filters are applied
                context.read<NavProvider>().setIndex(1);
              }
            },
          ),
        ),
        SizedBox(
          height: height,
          child: CategoryListWidget(
            categories: vm.categories,
            onCategoryTap: (cat) async {
              final sp = context.read<ServicesProvider>();
              await sp.init();
              if (!context.mounted) return;
              sp.search(cat.name);
              context.read<NavProvider>().setIndex(1);
            },
          ),
        ),
      ],
    );
  }

  //---------- Top Featured Vendors Section ---------
  Widget _buildTopFeaturedVendors(
    BuildContext context,
    double padding,
    double height, {
    List vendors = const [],
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
          child: TextNButtonWidget(
            title:
                context.read<HomeProvider>().sections?.vendorSectionTitle ??
                'Vendors',
            onTap: () => Get.toNamed(AppRoutes.vendors),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: HomeVendorCardListView(vendors: vendors.cast()),
        ),
      ],
    );
  }
}
