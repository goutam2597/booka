import 'dart:async';

import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A slim, unobtrusive banner shown at the top of the app.
/// - Shows an offline (pink) banner with a minimal Retry button when no internet.
/// - When connection returns, briefly shows a green "Back online" banner.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool? _lastOnline;
  bool _showBackOnline = false;
  bool _retrying = false;
  Timer? _backTimer;

  @override
  void dispose() {
    _backTimer?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    try {
      await context.read<ConnectivityProvider>().refreshNow();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityProvider>().isOnline;
    _lastOnline ??= online;

    // Detect transition: offline -> online
    if (_lastOnline == false && online == true && !_showBackOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _showBackOnline = true;
        });
        _backTimer?.cancel();
        _backTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => _showBackOnline = false);
        });
      });
    }
    _lastOnline = online;

    // Decide which banner to show
    final bool showOffline = !online;
    final bool showBack = online && _showBackOnline;
    if (!showOffline && !showBack) {
      return const SizedBox.shrink();
    }

    final Color bg = showBack
        ? AppColors.snackSuccess.withOpacity(0.98)
        : AppColors.secondaryColor.withOpacity(0.96);
    final IconData icon = showBack ? Icons.check_circle : Icons.wifi_off;
    final String message = showBack
        ? 'Back online — connection restored'
        : "You're offline — showing cached content";

    final textStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600);

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 4,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      style: textStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showOffline) ...[
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _retrying ? null : _retry,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.9)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: _retrying
                          ? const SizedBox(
                              height: 12,
                              width: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
