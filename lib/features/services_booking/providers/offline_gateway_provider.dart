import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Provider to manage the transient state of the offline payment dialog.
/// Mirrors the previous internal state of `OfflineGatewayDialog` without
/// changing any logic or return payload format.
class OfflineGatewayProvider extends ChangeNotifier {
  OfflineGatewayProvider({String? initialName}) {
    if (initialName != null && initialName.trim().isNotEmpty) {
      nameCtrl.text = initialName.trim();
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();

  File? pickedFile;
  bool submitting = false;
  bool attachmentError = false;

  bool get hasFile => pickedFile != null;

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    if (submitting) return;
    final ImagePicker picker = ImagePicker();
    final XFile? x = await picker.pickImage(source: ImageSource.gallery);
    if (x != null) {
      pickedFile = File(x.path);
      notifyListeners();
    }
  }

  bool _validate({required bool showAttachment, required bool attachmentRequired}) {
    attachmentError = false;
    final formValid = formKey.currentState?.validate() ?? false;
    if (!formValid) return false;
    if (showAttachment && attachmentRequired && pickedFile == null) {
      attachmentError = true;
      notifyListeners();
      return false;
    }
    return true;
  }

  void submit(BuildContext context, {
    required bool showAttachment,
    required bool attachmentRequired,
    required String attachmentFieldName,
  }) async {
    if (submitting) return;
    if (!_validate(showAttachment: showAttachment, attachmentRequired: attachmentRequired)) return;
    submitting = true;
    notifyListeners();
    try {
      Navigator.of(context).pop({
        'name': nameCtrl.text.trim(),
        'filePath': pickedFile?.path,
        'attachmentField': attachmentFieldName,
      });
    } finally {
      submitting = false;
      // Only notify if still mounted; guard via Scheduler? Simpler attempt/catch.
      try { notifyListeners(); } catch (_) {}
    }
  }
}
