import 'dart:ui';
import '../l10n/translations.dart';

class L10n {
  static String _locale = 'ko';

  static void init() {
    final language = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (language.startsWith('en')) {
      _locale = 'en';
    } else {
      _locale = 'ko';
    }
  }

  static String get locale => _locale;

  static void setLocale(String locale) {
    if (Translations.data.containsKey(locale)) {
      _locale = locale;
    }
  }

  static String t(String key) {
    return Translations.data[_locale]?[key] ?? key;
  }
}
