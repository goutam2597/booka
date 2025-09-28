import 'package:flutter/material.dart';
import 'package:bookapp_customer/network_service/core/review_network_service.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:bookapp_customer/features/services/providers/service_details_provider.dart';

class ServiceReviewsUiProvider extends ChangeNotifier {
  final TextEditingController commentCtrl = TextEditingController();
  int _rating = 5;
  bool _submitting = false;
  String? _response;
  bool _lastSuccess = false;

  int get rating => _rating;
  bool get submitting => _submitting;
  String? get response => _response;
  bool get lastSuccess => _lastSuccess;

  void setRating(int r) {
    if (_submitting) return;
    if (r < 1 || r > 5) return;
    _rating = r;
    notifyListeners();
  }

  Future<void> submit({
    required ServiceDetailsModel details,
    required ServiceDetailsProvider dataProvider,
  }) async {
    if (_submitting) return;
    if (commentCtrl.text.trim().isEmpty) return;
    _submitting = true;
    _response = null;
    _lastSuccess = false;
    notifyListeners();
    try {
      final result = await ReviewNetworkService.submitReview(
        serviceId: details.details.id,
        rating: _rating,
        comment: commentCtrl.text,
      );
      _response = result.message;
      _lastSuccess = result.success;
      if (result.success) {
        commentCtrl.clear();
        _rating = 5;
        // Identify slug for refresh
        final id = details.details.id;
        final slug = details.relatedServices.isNotEmpty
            ? details.relatedServices.first.slug
            : (details.details.vendor?.services.first.slug ?? '');
        if (slug.isNotEmpty) {
          await dataProvider.refresh(slug: slug, id: id);
        }
      }
    } catch (e) {
      _response = 'Failed: $e';
      _lastSuccess = false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }
}
