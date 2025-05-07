import 'dart:convert';
import 'package:flutter/services.dart';

class LanguageProvider {
  final Map<String, Map<String, String>> _localizedValues = {};
  String _currentLanguage = 'en';

  LanguageProvider() {
    _loadLanguages();
  }

  void _loadLanguages() async {
    _localizedValues['en'] = await _loadJson('../shared/localization/languages/en.json');
    _localizedValues['pl'] = await _loadJson('../shared/localization/languages/pl.json');
    _localizedValues['uk'] = await _loadJson('../shared/localization/languages/uk.json');
    
  }

  Future<Map<String, String>> _loadJson(String path) async {
    final jsonString = await rootBundle.loadString(path);
    return Map<String, String>.from(json.decode(jsonString));
  }

  String translate(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? key;
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
  }
}
