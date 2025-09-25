import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';

import '../../providers/service_details_provider.dart';
import '../../providers/service_details_ui_provider.dart';
import '../widgets/s_details_widgets/details_loading_prefill.dart';
import '../widgets/s_details_widgets/details_scaffold.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServicesModel? prefill;
  final String serviceSlug;
  final int serviceId;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceSlug,
    required this.serviceId,
    this.prefill,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ServiceDetailsProvider()
            ..load(slug: serviceSlug, id: serviceId),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceDetailsUiProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final dataProvider = context.watch<ServiceDetailsProvider>();
          final ServiceDetailsModel? details = dataProvider.details;

            if (details != null) {
              // Wrap ValueNotifiers via adapters for existing scaffold contract
              final ui = context.watch<ServiceDetailsUiProvider>();
              // Adapters to keep existing DetailsScaffold unchanged
              final selectedIndex = ValueNotifier<int>(ui.selectedIndex);
              selectedIndex.addListener(() => ui.setSelectedIndex(selectedIndex.value));
              final relatedMode = ValueNotifier<RelatedViewMode>(
                ui.relatedViewMode == RelatedViewMode.list
                    ? RelatedViewMode.list
                    : RelatedViewMode.grid,
              );
              relatedMode.addListener(() => ui.setRelatedViewMode(relatedMode.value));
              return DetailsScaffold(
                details: details,
                selectedIndex: selectedIndex,
                relatedViewMode: relatedMode,
              );
            }

          if (prefill != null) {
            return DetailsLoadingPrefill(prefill: prefill!);
          }
          return const Scaffold(body: Center(child: CustomCPI()));
        },
      ),
    );
  }
}
