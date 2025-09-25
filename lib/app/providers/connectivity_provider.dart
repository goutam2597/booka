import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkAndUpdate(); // initial check

    // listen for changes
    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      await _checkAndUpdate(result);
    });
  }

  Future<void> _checkAndUpdate([ConnectivityResult? result]) async {
    final connectivityResult =
        result ?? await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _setOnline(false);
      return;
    }

    // verify actual internet
    final ok = await _hasInternet();
    _setOnline(ok);
  }

  /// Public method to force a re-check of connectivity and internet reachability
  Future<void> refreshNow() async {
    await _checkAndUpdate();
  }

  Future<bool> _hasInternet() async {
    try {
      final res = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _setOnline(bool v) {
    if (_isOnline != v) {
      _isOnline = v;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
