import 'package:flutter/widgets.dart';

class WishlistUiProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  String _query = '';

  String get query => _query;

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clear() {
    searchController.clear();
    setQuery('');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
