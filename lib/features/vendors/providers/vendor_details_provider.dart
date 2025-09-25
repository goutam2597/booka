import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/network_service/core/vendor_network_service.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';

class VendorDetailsState {
  final bool loading;
  final VendorDetailsModel? data;
  final String? error;

  const VendorDetailsState({required this.loading, this.data, this.error});

  VendorDetailsState copyWith({
    bool? loading,
    VendorDetailsModel? data,
    String? error,
  }) {
    return VendorDetailsState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class VendorDetailsProvider extends ChangeNotifier {
  final Map<String, VendorDetailsState> _states = {};
  // Simple in-memory cache shared across provider instances so that when the
  // screen is rebuilt (new provider instance) we can reuse already fetched
  // vendor details without flashing a loading state.
  static final Map<String, VendorDetailsModel> _cache = {};
  static final Map<String, DateTime> _cacheTimes = {};
  // Optional TTL (set to null for infinite). Adjust if you want auto refresh.
  static const Duration? _ttl = null; // e.g. Duration(minutes: 5);

  VendorDetailsState stateFor(String username) {
    return _states[username] ?? const VendorDetailsState(loading: false);
  }

  Future<void> fetch(String username, {bool forceRefresh = false}) async {
    final current = _states[username];

    // Serve from cache if we have it and no force refresh requested.
    if (!forceRefresh) {
      final cached = _cache[username];
      if (cached != null) {
        final ts = _cacheTimes[username];
        final isExpired = _ttl != null && ts != null && DateTime.now().difference(ts) > _ttl!;
        if (!isExpired) {
          // Populate local state map if this provider instance is new.
            if (current?.data == null) {
            _states[username] = VendorDetailsState(loading: false, data: cached);
            notifyListeners();
          }
          return; // skip network
        }
      }
    }

    if (!forceRefresh && current?.data != null) return; // already have fresh data in this instance

    _states[username] = VendorDetailsState(loading: true, data: current?.data);
    notifyListeners();

    try {
      final details = await VendorNetworkService.getVendorDetails(username);
      _states[username] = VendorDetailsState(loading: false, data: details);
      // Store in global cache
      _cache[username] = details;
      _cacheTimes[username] = DateTime.now();
      notifyListeners();
    } catch (e) {
      _states[username] = VendorDetailsState(
        loading: false,
        data: current?.data,
        error: e.toString(),
      );
      notifyListeners();
    }
  }
}
