import 'package:bookapp_customer/features/home/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/ui/widgets/services_card_widget_for_grid.dart';

import '../../../../app/routes/app_routes.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryModel category;
  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CategoryProvider>();
    final loading = store.loading(category.name);
    final err = store.error(category.name);
    final List<ServicesModel>? data = store.get(category.name);

    if (!loading && data == null && err == null) {
      Future.microtask(() {
        if (context.mounted) {
          context.read<CategoryProvider>().fetch(category.name);
        }
      });
    }

    return Scaffold(
      body: Builder(
        builder: (_) {
          if (loading && data == null) {
            return const Center(child: CustomCPI());
          }
          if (err != null && data == null) {
            return Column(
              children: [
                CustomAppBar(
                  title: category.name,
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Get.toNamed(AppRoutes.bottomNav);
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(err),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context
                              .read<CategoryProvider>()
                              .refresh(category.name),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final services = data ?? const <ServicesModel>[];
          if (services.isEmpty) {
            return Column(
              children: [
                CustomAppBar(title: category.name),
                Expanded(
                  child: Center(
                    child: Text('No services found for ${category.name}'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              CustomAppBar(title: category.name),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double spacing = 8;
                      final itemWidth = (constraints.maxWidth - spacing) / 2;

                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<CategoryProvider>()
                            .refresh(category.name),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: List.generate(services.length, (index) {
                              final item = services[index];
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                columnCount: 2,
                                child: ScaleAnimation(
                                  scale: 0.85,
                                  child: FadeInAnimation(
                                    child: SizedBox(
                                      width: itemWidth,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Get.toNamed(
                                            AppRoutes.serviceDetails,
                                            arguments: {
                                              'slug': item.slug,
                                              'id': item.id,
                                            },
                                          );
                                        },
                                        child: ServicesCardWidgetForGrid(
                                          item: item,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
