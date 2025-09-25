import 'package:bookapp_customer/network_service/core/wishlist_network_service.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
// lib/features/wishlist/providers/wishlist_provider.dart
import 'package:flutter/foundation.dart';
import 'package:bookapp_customer/features/wishlist/data/models/wishlist_model.dart';
import 'package:bookapp_customer/features/wishlist/data/wishlist_repository.dart';
import 'package:bookapp_customer/features/wishlist/data/wishlist_action_result.dart';

enum WishlistStatus { idle, loading, error }

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _repo;
  WishlistProvider({WishlistRepository? repo})
      : _repo = repo ?? const WishlistRepository() {
    // React to login/logout to keep wishlist in sync
    AuthAndNetworkService.isLoggedIn.addListener(_onAuthChange);
  }

  WishlistStatus status = WishlistStatus.idle;

  final List<WishlistModel> _items = [];
  final Set<int> _ids = {}; // single source of truth for quick checks
  String _pageTitle = '';

  List<WishlistModel> get items => List.unmodifiable(_items);
  bool isInWishlist(int serviceId) => _ids.contains(serviceId);
  String get pageTitle {
    if (_pageTitle.trim().isNotEmpty) return _pageTitle.trim();
    if (_items.isNotEmpty) {
      final t = _items.first.wishlistPageTitle.trim();
      if (t.isNotEmpty) return t;
    }
    return 'Wishlist';
  }

  void _onAuthChange() {
    final loggedIn = AuthAndNetworkService.isLoggedIn.value;
    if (!loggedIn) {
      _items.clear();
      _ids.clear();
      _pageTitle = '';
      status = WishlistStatus.idle;
      notifyListeners();
    } else {
      // Re-fetch wishlist on login
      refresh();
    }
  }

  Future<void> refresh() async {
    status = WishlistStatus.loading;
    notifyListeners();
    try {
      final list = await _repo.fetchWishlist();
      _items
        ..clear()
        ..addAll(list);
      _ids
        ..clear()
        ..addAll(list.map((e) => e.serviceId));
      if (_items.isNotEmpty) {
        _pageTitle = _items.first.wishlistPageTitle.trim();
      } else {
        try {
          final t = await WishlistNetworkService.getWishListTitle();
          if (t.isNotEmpty) _pageTitle = t;
        } catch (_) {}
      }
      status = WishlistStatus.idle;
      notifyListeners();
    } catch (_) {
      status = WishlistStatus.error;
      notifyListeners();
    }
  }

  /// REMOVE by id (optimistic on ids; items fixed by refresh if needed)
  Future<WishlistActionResult> removeByServiceId(int serviceId) async {
    if (!_ids.contains(serviceId)) {
      return const WishlistActionResult(ok: true, message: 'Already removed');
    }

    // optimistic: update ids (and items best-effort if present)
    final idx = _items.indexWhere((e) => e.serviceId == serviceId);
    WishlistModel? removed;
    if (idx != -1) removed = _items.removeAt(idx);
    _ids.remove(serviceId);
    notifyListeners();

    final res = await _repo.remove(serviceId);
    if (!res.ok) {
      // rollback
      if (removed != null && idx != -1) _items.insert(idx, removed);
      _ids.add(serviceId);
      notifyListeners();
    }
    return res;
  }


  Future<WishlistActionResult> addByServiceId(int serviceId,
      {bool optimisticIds = true}) async {
    if (_ids.contains(serviceId)) {
      return const WishlistActionResult(ok: true, message: 'Already in wishlist');
    }

    if (optimisticIds) {
      _ids.add(serviceId);
      notifyListeners();
    }

    final res = await _repo.add(serviceId);
    if (!res.ok) {
      if (optimisticIds) {
        _ids.remove(serviceId);
        notifyListeners();
      }
      return res;
    }


    await refresh();
    return res;
  }

  @override
  void dispose() {
    AuthAndNetworkService.isLoggedIn.removeListener(_onAuthChange);
    super.dispose();
  }
}


