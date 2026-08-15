import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/game_constants.dart';

enum AppLanguage { arabic, english }

/// Central localization manager. UI code must never hardcode strings —
/// always go through `language.text(ar: ..., en: ...)`.
class AppLanguageManager extends ChangeNotifier {
  AppLanguage _current = AppLanguage.english;

  AppLanguage get current => _current;

  bool get isArabic => _current == AppLanguage.arabic;

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Locale get locale => Locale(isArabic ? 'ar' : 'en');

  static const _prefsKey = '${GameConstants.prefsPrefix}language';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'ar') {
        _current = AppLanguage.arabic;
      } else if (saved == 'en') {
        _current = AppLanguage.english;
      }
      notifyListeners();
    } catch (_) {
      // Keep default language if prefs unavailable.
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    _current = language;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, language == AppLanguage.arabic ? 'ar' : 'en');
    } catch (_) {
      // Non-fatal: language still applies for this session.
    }
  }

  Future<void> toggle() async {
    await setLanguage(isArabic ? AppLanguage.english : AppLanguage.arabic);
  }

  /// Returns the correct string for the current language.
  String text({required String ar, required String en}) {
    return isArabic ? ar : en;
  }
}
