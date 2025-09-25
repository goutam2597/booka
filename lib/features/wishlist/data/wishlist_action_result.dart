class WishlistActionResult {
  final bool ok;
  final String message;
  const WishlistActionResult({required this.ok, required this.message});

  static const success = WishlistActionResult(ok: true, message: 'Success');
  static const failure = WishlistActionResult(ok: false, message: 'Failed');
}
