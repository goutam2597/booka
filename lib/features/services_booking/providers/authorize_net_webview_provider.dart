import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:bookapp_customer/app/urls.dart';

/// Provider encapsulating state for Authorize.Net webview (token or checkout URL).
class AuthorizeNetWebviewProvider extends ChangeNotifier {
  AuthorizeNetWebviewProvider({
    required this.successScheme,
    required this.cancelScheme,
    this.checkoutUrl,
    this.token,
    this.title = 'Authorize.Net',
  }) : assert(checkoutUrl != null || token != null, 'Provide either checkoutUrl or token');

  final String? checkoutUrl;
  final String? token;
  final String successScheme;
  final String cancelScheme;
  final String title;

  late final WebViewController controller;
  bool _loading = true;
  String? _lastError;
  bool _finished = false;
  bool _initialized = false;

  bool get loading => _loading;
  String? get lastError => _lastError;
  bool get finished => _finished;
  bool get initialized => _initialized;

  void init() {
    if (_initialized) return;
    _initialized = true;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _loading = true;
            if (url.startsWith(successScheme)) {
              controller.loadRequest(Uri.parse('about:blank'));
              _finish(true);
            } else if (url.startsWith(cancelScheme)) {
              controller.loadRequest(Uri.parse('about:blank'));
              _finish(false);
            }
            notifyListeners();
          },
          onPageFinished: (_) {
            _loading = false;
            notifyListeners();
          },
          onWebResourceError: (err) {
            _lastError = '${err.errorCode}: ${err.description}';
            _loading = false;
            notifyListeners();
          },
          onUrlChange: (change) {
            final url = change.url ?? '';
            if (url.startsWith(successScheme)) {
              controller.loadRequest(Uri.parse('about:blank'));
              _finish(true);
            } else if (url.startsWith(cancelScheme)) {
              controller.loadRequest(Uri.parse('about:blank'));
              _finish(false);
            }
          },
          onNavigationRequest: (req) {
            final url = req.url;
            if (url.startsWith(successScheme)) {
              _finish(true);
              return NavigationDecision.prevent;
            }
            if (url.startsWith(cancelScheme)) {
              _finish(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _initialLoad();
  }

  void _initialLoad() {
    if (checkoutUrl != null) {
      controller.loadRequest(Uri.parse(checkoutUrl!));
    } else {
      final escaped = const HtmlEscape().convert(token!);
      final html = '<!doctype html>\n<html><head><meta charset="utf-8"><title>Authorize.Net</title></head>'
          '<body onload="document.forms[0].submit()" style="margin:0;padding:0;">'
          '<form method="post" action="${Urls.authorizeNetHostedPaymentUrl}">'
          '<input type="hidden" name="token" value="$escaped" />'
          '<noscript><button type="submit">Continue</button></noscript>'
          '</form></body></html>';
      controller.loadHtmlString(html);
    }
  }

  void retry() {
    _lastError = null;
    _loading = true;
    notifyListeners();
    _initialLoad();
  }

  void _finish(bool success) {
    if (_finished) return;
    _finished = true;
    // Pop handled by widget.
    notifyListeners();
  }
}
