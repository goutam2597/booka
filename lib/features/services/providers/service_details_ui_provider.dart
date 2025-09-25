import 'package:flutter/foundation.dart';

/// UI-only provider for Service Details screen ephemeral state.
/// Replaces internal ValueNotifiers previously held inside `_ServiceDetailsViewState`.
class ServiceDetailsUiProvider extends ChangeNotifier {
  int _selectedIndex = 0; // e.g., active tab / segment
  int get selectedIndex => _selectedIndex;

  RelatedViewMode _relatedViewMode = RelatedViewMode.list;
  RelatedViewMode get relatedViewMode => _relatedViewMode;

  void setSelectedIndex(int i) {
    if (i == _selectedIndex) return;
    _selectedIndex = i;
    notifyListeners();
  }

  void toggleRelatedViewMode() {
    _relatedViewMode = _relatedViewMode == RelatedViewMode.list
        ? RelatedViewMode.grid
        : RelatedViewMode.list;
    notifyListeners();
  }

  void setRelatedViewMode(RelatedViewMode mode) {
    if (mode == _relatedViewMode) return;
    _relatedViewMode = mode;
    notifyListeners();
  }
}

/// Copied enum locally to avoid import cycle risk; ensure it matches original.
enum RelatedViewMode { list, grid }
