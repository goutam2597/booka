import 'package:bookapp_customer/features/services_booking/providers/checkout_webview_provider.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/pgw_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutWebView extends StatelessWidget {
  final String url;
  final String finishScheme;
  final String title;

  const CheckoutWebView({
    super.key,
    required this.url,
    required this.finishScheme,
    this.title = 'Checkout',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutWebViewProvider(
        url: url,
        finishScheme: finishScheme,
        title: title,
      )..init(),
      builder: (context, _) {
        final p = context.watch<CheckoutWebViewProvider>();
        if (p.finished) {
          // Pop once finish detected (async post frame guard)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop(true);
            }
          });
        }
        return Scaffold(
          body: Column(
            children: [
              PGWAppBar(title: p.title),
              if (!p.initialized)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(child: WebViewWidget(controller: p.controller)),
            ],
          ),
        );
      },
    );
  }
}
