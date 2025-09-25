import 'package:get/get.dart';

import '../../network_service/core/lang_service.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': const {},
    'ar': LangService.mapOf('ar'),
  };
}
