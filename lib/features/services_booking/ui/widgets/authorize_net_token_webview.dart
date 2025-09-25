import 'package:bookapp_customer/features/services_booking/providers/authorize_net_webview_provider.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/pgw_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Stateless wrapper using provider for state.
class AuthorizeNetWebView extends StatelessWidget {
  final String? checkoutUrl;
  final String? token;
  final String successScheme;
  final String cancelScheme;
  final String title;

  const AuthorizeNetWebView({
    super.key,
    required this.successScheme,
    required this.cancelScheme,
    this.checkoutUrl,
    this.token,
    this.title = 'Authorize.Net',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthorizeNetWebviewProvider(
        successScheme: successScheme,
        cancelScheme: cancelScheme,
        checkoutUrl: checkoutUrl,
        token: token,
        title: title,
      )..init(),
      builder: (context, _) {
        final p = context.watch<AuthorizeNetWebviewProvider>();
        if (p.finished) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop(p.finished);
            }
          });
        }
        return Scaffold(
          body: Column(
            children: [
              PGWAppBar(title: p.title),
              Expanded(
                child: Stack(
                  children: [
                    if (!p.initialized)
                      const SizedBox.shrink()
                    else
                      WebViewWidget(controller: p.controller),
                    if (p.loading)
                      const Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (p.lastError != null)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withAlpha(4),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 42),
                              const SizedBox(height: 12),
                              Text('Failed to load',
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 6),
                              Text(
                                p.lastError!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: p.retry,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
