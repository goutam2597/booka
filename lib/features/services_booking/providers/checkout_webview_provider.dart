import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Provider that encapsulates the state previously held inside
/// the CheckoutWebView StatefulWidget. No business logic changed.
class CheckoutWebViewProvider extends ChangeNotifier {
  CheckoutWebViewProvider({
    required this.url,
    required this.finishScheme,
    required this.title,
  });

  final String url;
  final String finishScheme;
  final String title;

  late final WebViewController controller;
  bool _finished = false;
  bool _initialized = false;

  bool get initialized => _initialized;

  void init() {
    if (_initialized) return;
    _initialized = true;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (u) => _maybeFinish(u),
          onUrlChange: (change) => _maybeFinish(change.url ?? ''),
          onNavigationRequest: (req) {
            if (_isFinish(req.url)) {
              _finish();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  bool _isFinish(String url) => url.startsWith(finishScheme) || url.startsWith('myapp://');

  void _maybeFinish(String url) {
    if (_isFinish(url)) {
      controller.loadRequest(Uri.parse('about:blank'));
      _finish();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    // Navigator pop handled by widget using provider flag.
    notifyListeners();
  }

  bool get finished => _finished;
}
