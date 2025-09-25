import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';

import '../../../../network_service/core/services_network_service.dart';

class ServicesRepository {
  final ServicesNetworkService _api = ServicesNetworkService();

  final Map<int, ServiceDetailsModel> _detailsById = {};

  bool hasDetails(int id) => _detailsById.containsKey(id);
  ServiceDetailsModel? peekDetails(int id) => _detailsById[id];

  Future<ServiceDetailsModel> getDetails({
    required String slug,
    required int id,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _detailsById.containsKey(id)) {
      return _detailsById[id]!;
    }
    final fresh = await _api.getServiceDetails(slug, id);
    _detailsById[id] = fresh;
    return fresh;
  }
}
