import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'currency': 'Currency',
      'data_wipe': 'Wipe All Data',
      'about_app': 'About App',
      'app_description': 'This is a budget tracking app.',
      'app_version': 'Version: 1.0.0',
      'confirm_wipe': 'Are you sure you want to wipe all data?',
      'data_wipe_message': 'All data has been wiped successfully.',
    },

    'vi': {
      'settings': 'Cài đặt',
      'dark_mode': 'Chế độ tối',
      'language': 'Ngôn ngữ',
      'currency': 'Tiền tệ',
      'data_wipe': 'Xoá tất cả dữ liệu',
      'about_app': 'Thông tin về ứng dụng',
      'app_description': 'Đây là ứng dụng theo dõi ngân sách.',
      'app_version': 'Phiên bản: 1.0.0',
      'confirm_wipe': 'Bạn có chắc chắn muốn xoá tất cả dữ liệu?',
      'data_wipe_message': 'Tất cả dữ liệu đã được xoá thành công.',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]![key]!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}