import 'package:flutter/material.dart';

/*
* This handles the translation for the app.
* */
class AppLocalizations {
  final Locale locale; // Current app local (either 'en' or 'vi')

  // Constructor for AppLocalizations.
  AppLocalizations(this.locale);

  /*
  * Retrieves the AppLocalizations instance
  * from the nearest Localizations widget in the widget tree.
  * This allows access to the localized strings within the current context.
  * */
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // A map of all localized strings in different languages.
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // budget_setup_dialog
      'Please select a start date first.': 'Please select a start date first.',
      'Please fill all fields correctly.': 'Please fill all fields correctly.',
      'Set Your Budget': 'Set Your Budget',
      'Enter your initial budget': 'Enter your initial budget',
      'Initial Budget': 'Initial Budget',
      'Select Start Date': 'Select Start Date',
      'Start Date ': 'Start Date',
      'Select End Date': 'Select End Date',
      'End Date': 'End Date',

      // settings_screen.dart
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'currency': 'Currency',
      'data_wipe': 'Wipe All Data',
      'confirm_wipe': 'Are you sure you want to wipe all data?',
      'data_wipe_message': 'All data has been wiped successfully.',
      'about_app': 'About App',
      'app_description': 'This is a budget tracking app.',
      'app_version': 'Version: 1.0.0',

      // confirmation dialog
      'confirmation': 'Delete Confirmation',
      'confirm': 'Confirm',
      'cancel': 'Cancel',

      // statistics screen
      'statistics': 'Statistics',
      'Spending Category': 'Spending Category',
      'Spending Trend': 'Spending Trend',

      // update transaction
      'InvalidAmount': 'Invalid amount entered',
      'Update Transaction': 'Update Transaction',
      'Amount': 'Amount',
      'Enter Amount': 'Enter Amount',
      'Type: ': 'Type: ',
      'Expense': 'Expense',
      'Income': 'Income',
      'Tag:': 'Tag:',
      'Note:': 'Note:',
      'Add a note...': 'Add a note...',

      // new transaction
      'New Transaction': 'New Transaction',
      'AMOUNT:': 'AMOUNT:',
      'TYPE:': 'TYPE:',
      'TAG:': 'TAG:',
      'Food': 'Food',
      'Transport': 'Transport',
      'Entertainment': 'Entertainment',
      'Bills': 'Bills',
      'Shopping': 'Shopping',
      'Travel': 'Travel',
      'Health': 'Health',
      'Gifts': 'Gifts',
      'Others': 'Others',
      'NOTE:': 'NOTE:',
      'e.g. Bought The End and The Death part 1 from Amazon':
      'e.g. Bought The End and The Death part 1 from Amazon',
      'Save Transaction': 'Save Transaction',

      // home screen
      'Congratulations!': 'Congratulations!',
      'You have successfully completed your budget period.':
      'You have successfully completed your budget period.',
      'Not yet!': 'Not yet!',
      'OVER BUDGET!': 'OVER BUDGET!',
      'Daily Budget': 'Daily Budget',
      'Over budget mate!': 'Over budget mate!',
      'Days Left:': 'Days Left:',
      'Start Date:': 'Start Date:',
      'End Date:': 'End Date:',

      // calendar
      'CalenderScreen': 'Transaction Calendar',
      'No transactions found': 'No transactions found',
    },
    'vi': {
      // budget_setup_dialog
      'Please select a start date first.': 'Vui lòng chọn ngày bắt đầu trước.',
      'Please fill all fields correctly.':
      'Vui lòng điền đúng tất cả các trường.',
      'Set Your Budget': 'Đặt ngân sách của bạn',
      'Enter your initial budget': 'Nhập ngân sách ban đầu của bạn',
      'Initial Budget': 'Ngân sách ban đầu',
      'Select Start Date': 'Chọn ngày bắt đầu',
      'Start_date': 'Ngày bắt đầu',
      'Select End Date': 'Chọn ngày kết thúc',
      'End Date': 'Ngày kết thúc',

      // settings_screen.dart
      'settings': 'Cài đặt',
      'dark_mode': 'Chế độ tối',
      'language': 'Ngôn ngữ',
      'currency': 'Tiền tệ',
      'data_wipe': 'Xoá tất cả dữ liệu',
      'confirm_wipe': 'Bạn có chắc chắn muốn xoá tất cả dữ liệu?',
      'data_wipe_message': 'Tất cả dữ liệu đã được xoá thành công.',
      'about_app': 'Thông tin về ứng dụng',
      'app_description': 'Đây là ứng dụng theo dõi ngân sách.',
      'app_version': 'Phiên bản: 1.0.0',

      // confirmation dialog - confirm and cancel dùng chung
      'confirmation': 'Xác nhận xoá',
      'confirm': 'Xác nhận',
      'cancel': 'Hủy',

      // statistics screen
      'statistics': 'Thống kê',
      'Spending Category': 'Danh mục chi tiêu',
      'Spending Trend': 'Xu hướng chi tiêu',

      // update transaction
      'InvalidAmount': 'Số tiền không hợp lệ',
      'Update Transaction': 'Cập nhật giao dịch',
      'Amount': 'Số tiền',
      'Enter Amount': 'Nhập số tiền',
      'Type: ': 'Loại: ',
      'Expense': 'Chi phí',
      'Income': 'Thu nhập',
      'Tag:': 'Thẻ:',
      'Note:': 'Ghi chú:',
      'Add a note...': 'Thêm ghi chú...',

      // new transaction
      'New Transaction': 'Giao dịch mới',
      'AMOUNT:': 'SỐ TIỀN:',
      'TYPE:': 'LOẠI:',
      'TAG:': 'THẺ:',
      'NOTE:': 'GHI CHÚ:',
      'Food': 'Thức ăn',
      'Transport': 'Vận chuyển',
      'Entertainment': 'Giải trí',
      'Bills': 'Hóa đơn',
      'Shopping': 'Mua sắm',
      'Travel': 'Du lịch',
      'Health': 'Sức khỏe',
      'Gifts': 'Quà tặng',
      'Others': 'Khác',
      'e.g. Bought The End and The Death part 1 from Amazon':
      'ví dụ: Mua The End và The Death phần 1 từ Amazon',
      'Save Transaction': 'Lưu giao dịch',

      // home screen
      'Congratulations!': 'Chúc mừng!',
      'You have successfully completed your budget period.':
      'Bạn đã hoàn thành kỳ ngân sách của mình thành công.',
      'Not yet!': 'Chưa đến!',
      'OVER BUDGET!': 'VƯỢT QUÁ NGÂN SÁCH!',
      'Daily Budget': 'Ngân Sách Hôm Nay',
      'Over budget mate!': 'Vượt quá ngân sách bạn ơi!',
      'Days Left:': 'Còn lại:',
      'Start Date:': 'Ngày bắt đầu:',
      'End Date:': 'Ngày kết thúc:',

      // calendar
      'CalenderScreen': 'Lịch giao dịch',
      'No transactions found': 'Không tìm thấy giao dịch',
    },
  };

  /*
  * Function to get the localized string of a given key.
  * If not found return the key itself.
  * */
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

/*
* A class that implements the LocalizationsDelegate for AppLocalizations.
* Which is a factory for AppLocalizations to loads translations based on locale
* and handles locale changes.
*/
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();  // Constructor for AppLocalizationsDelegate.

  // Check if local is support by this delegate.
  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  // Load the AppLocalizations based on locale.
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  // Reload the AppLocalizations when locale changes.
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

