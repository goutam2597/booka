import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:flutter/foundation.dart';
import '../../../../network_service/core/services_network_service.dart';

class ServiceDetailsProvider extends ChangeNotifier {
  final ServicesNetworkService _api = ServicesNetworkService();

  // Persist across instances so reopening the screen doesn't refetch immediately
  static final Map<int, ServiceDetailsModel> _cacheById = {};

  ServiceDetailsModel? _details;
  bool _loading = false;
  Object? _error;

  ServiceDetailsModel? get details => _details;
  bool get isLoading => _loading;
  Object? get error => _error;

  Future<void> load({
    required String slug,
    required int id,
    bool refresh = false,
  }) async {
    // Serve from cache immediately (no spinner)
    if (!refresh && _cacheById.containsKey(id)) {
      _details = _cacheById[id];
      _loading = false;
      _error = null;
      notifyListeners();
      // Optional: background refresh to keep data fresh
      _silentRefresh(slug: slug, id: id);
      return;
    }

    _loading = true;
    _error = null;
    _details = null;
    notifyListeners();

    try {
      final d = await _api.getServiceDetails(slug, id);
      _cacheById[id] = d;
      _details = d;
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Public method to silently refresh (used after review submission).
  Future<void> refresh({required String slug, required int id}) {
    return _silentRefresh(slug: slug, id: id);
  }

  Future<void> _silentRefresh({required String slug, required int id}) async {
    try {
      final fresh = await _api.getServiceDetails(slug, id);
      _cacheById[id] = fresh;

      // Only update if we're still looking at the same service
      if (_details?.details.id == id) {
        _details = fresh;
        notifyListeners();
      }
    } catch (_) {}
  }
}
