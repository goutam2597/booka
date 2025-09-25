import 'package:bookapp_customer/features/wishlist/data/models/wishlist_model.dart';
import 'package:bookapp_customer/features/wishlist/data/wishlist_action_result.dart';
import 'package:bookapp_customer/network_service/core/wishlist_network_service.dart';

class WishlistRepository {
  const WishlistRepository();

  Future<List<WishlistModel>> fetchWishlist() {
    return WishlistNetworkService.getWishList();
  }

  Future<WishlistActionResult> add(int serviceId) async {
    final msg = await WishlistNetworkService.addToWishlist(serviceId);
    final lower = msg.toLowerCase();
    final ok = !(lower.contains('error') ||
        lower.contains('login') ||
        lower.contains('wrong') ||
        lower.contains('fail'));
    return WishlistActionResult(ok: ok, message: msg);
  }

  Future<WishlistActionResult> remove(int serviceId) async {
    final ok = await WishlistNetworkService.removeFromWishlist(serviceId);
    return WishlistActionResult(
      ok: ok,
      message: ok ? 'Removed From wishlist successfully' : 'Failed to remove item.',
    );
  }
}
