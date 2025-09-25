import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/providers/locale_provider.dart';
import 'package:bookapp_customer/features/account/providers/legal_pages_provider.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class LegalScreen extends StatefulWidget {
  final String title;
  final String? pageKey;
  final String? match;
  const LegalScreen({super.key, required this.title, this.pageKey, this.match});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  String _pageKey = 'terms';
  String _lastLangCode = '';

  @override
  void initState() {
    super.initState();
    _pageKey = _deriveKey(widget.pageKey, widget.match);
  }

  String _deriveKey(String? pageKey, String? match) {
    if (pageKey == 'privacy' || pageKey == 'terms') return pageKey!;
    final m = (match ?? '').toLowerCase();
    if (m.contains('privacy') || m.contains('policy')) return 'privacy';
    return 'terms';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LegalPagesProvider>(
      create: (ctx) {
        final lang = ctx.read<LocaleProvider>().locale.languageCode;
        _lastLangCode = lang;
        final prov = LegalPagesProvider(languageCode: lang);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          prov.ensureLoaded(_pageKey);
        });
        return prov;
      },
      builder: (ctx, _) {
        final lp = ctx.watch<LocaleProvider>();
        final prov = ctx.watch<LegalPagesProvider>();
        if (_lastLangCode != lp.locale.languageCode) {
          _lastLangCode = lp.locale.languageCode;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            prov.onLanguageChanged(_lastLangCode);
            await prov.ensureLoaded(_pageKey);
          });
        }
        final html = _pageKey == 'privacy' ? prov.privacyHtml : prov.termsHtml;
        return Scaffold(
          body: Column(
            children: [
              CustomAppBar(title: widget.title),
              Expanded(
                child: prov.loading
                    ? const Center(child: CircularProgressIndicator())
                    : prov.error != null
                    ? _ErrorView(
                        message: prov.error!,
                        onRetry: () => prov.refresh(_pageKey),
                      )
                    : (html == null || html.isEmpty)
                    ? _EmptyView(onRetry: () => prov.refresh(_pageKey))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Html(
                          data: html,
                          style: {
                            'body': Style(
                              color: Colors.black87,
                              fontSize: FontSize.medium,
                              lineHeight: const LineHeight(1.5),
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            ),
                            'h1': Style(color: AppColors.primaryColor),
                            'h2': Style(color: AppColors.primaryColor),
                            'h3': Style(color: AppColors.primaryColor),
                            'h4': Style(color: AppColors.primaryColor),
                            'a': Style(color: AppColors.secondaryColor),
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No content found'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
