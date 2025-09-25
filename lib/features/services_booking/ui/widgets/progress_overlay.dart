import 'package:flutter/material.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:get/get.dart';

class ProgressOverlay {
  ProgressOverlay._(this._context);

  final BuildContext _context;
  bool _visible = false;
  final ValueNotifier<String> _msg = ValueNotifier<String>('processing'.tr);

  static ProgressOverlay of(BuildContext context) => ProgressOverlay._(context);

  void show(String message) {
    if (_visible) {
      _msg.value = message;
      return;
    }
    _visible = true;
    _msg.value = message;

    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCPI(),
                const SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: _msg,
                  builder: (_, value, _) => Text(
                    value,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _visible = false);
  }

  void update(String message) => _msg.value = message;

  void hide() {
    if (_visible && Navigator.of(_context, rootNavigator: true).canPop()) {
      Navigator.of(_context, rootNavigator: true).pop();
    }
  }
}
