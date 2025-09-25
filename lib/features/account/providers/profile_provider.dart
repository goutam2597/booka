import 'dart:io';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bookapp_customer/network_service/core/profile_network_service.dart';

class ProfileProvider extends ChangeNotifier {
  File? _imageFile;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isFetching = true;
  String? _lastMessage;

  File? get imageFile => _imageFile;
  String? get profileImageUrl => _profileImageUrl;
  bool get isLoading => _isLoading;
  bool get isFetching => _isFetching;
  String? get lastMessage => _lastMessage;

  final Map<String, TextEditingController> controllers = {
    'username': TextEditingController(),
    'name': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'state': TextEditingController(),
    'zip': TextEditingController(),
    'country': TextEditingController(),
    'address': TextEditingController(),
  };

  ProfileProvider() {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isFetching = true;
    _lastMessage = null;
    notifyListeners();

    final result = await ProfileNetworkService.getProfile();
    if (result['success'] == true &&
        result['data'] != null &&
        result['data']['authUser'] != null) {
      final user = result['data']['authUser'];
      controllers['username']!.text = user['username'] ?? '';
      controllers['name']!.text = user['name'] ?? '';
      controllers['email']!.text = user['email'] ?? '';
      controllers['phone']!.text = user['phone'] ?? '';
      controllers['state']!.text = user['state'] ?? '';
      controllers['zip']!.text = user['zip_code'] ?? '';
      controllers['country']!.text = user['country'] ?? '';
      controllers['address']!.text = user['address'] ?? '';

      if (user['image'] != null && (user['image'] as String).isNotEmpty) {
        final img = user['image'] as String;
        _profileImageUrl = img.startsWith('http')
            ? img
            : AssetsPath.userPlaceholderPng;
      } else {
        // If the API image is null or empty, use the default local placeholder asset
        _profileImageUrl = AssetsPath.userPlaceholderPng;
      }
    } else {
      _lastMessage = result['message'] ?? 'Failed to fetch profile data!';
    }

    _isFetching = false;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _imageFile = File(picked.path);
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    _isLoading = true;
    _lastMessage = null;
    notifyListeners();

    final result = await ProfileNetworkService.updateProfile(
      username: controllers['username']!.text.trim(),
      name: controllers['name']!.text.trim(),
      email: controllers['email']!.text.trim(),
      phone: controllers['phone']!.text.trim(),
      state: controllers['state']!.text.trim(),
      zipCode: controllers['zip']!.text.trim(),
      country: controllers['country']!.text.trim(),
      address: controllers['address']!.text.trim(),
      image: _imageFile,
    );

    _isLoading = false;

    final success = result['success'] == true;
    _lastMessage =
        result['message'] ??
        (success
            ? 'Profile updated successfully!'
            : 'Failed to update profile!');

    if (success) {
      await fetchProfile();
      _imageFile = null;
    } else {
      notifyListeners();
    }

    return success;
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
