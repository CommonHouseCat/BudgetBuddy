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
      'confirm_wipe': 'Are you sure you want to wipe all data?',
      'data_wipe_message': 'All data has been wiped successfully.',
      'about_app': 'About App',
      'app_description': 'This is a budget tracking app.',
      'app_version': 'Version: 1.0.0',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'confirmation': 'Delete Confirmation',
      'statistics': 'Statistics',
      'Set Your Budget': 'Set Your Budget',
      'Enter your initial budget': 'Enter your initial budget',
      'Initial Budget': 'Initial Budget',
      'Select Start Date': 'Select Start Date',
      'Start Date ': 'Start Date',
      'Select End Date': 'Select End Date',
      'End Date': 'End Date',
      'Update Transaction': 'Update Transaction',
      'Amount': 'Amount',
      'Enter Amount': 'Enter Amount',
      'Type: ': 'Type: ',
      'Expense': 'Expense',
      'Income': 'Income',
      'Tag:': 'Tag:',
      'Note:': 'Note:',
      'Add a note...': 'Add a note...',
      'New Transaction': 'New Transaction',
      'AMOUNT:': 'AMOUNT:',
      'TYPE:': 'TYPE:',
      'TAG:': 'TAG:',
      'NOTE:': 'NOTE:',
      'e.g. Bought The End and The Death part 1 from Amazon':
      'e.g. Bought The End and The Death part 1 from Amazon',
      'Save Transaction': 'Save Transaction',
      'OVER BUDGET!': 'OVER BUDGET!',
      'Daily Budget': 'Daily Budget',
      'Over budget mate!': 'Over budget mate!',
      'Days Left:': 'Days Left:',
      'Start Date:': 'Start Date:',
      'End Date:': 'End Date:',
      'Spending Trend': 'Spending Trend',
      'Spending Category': 'Spending Category',
      'CalenderScreen': 'Transaction History',
      'SelectStartDate' : 'Please select a start date first',
      'FillCorrectlyWarning': 'Please fill all fields correctly',
      'InvalidAmount': 'Invalid amount entered',
    },
    'vi': {
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
      'confirm': 'Xác nhận',
      'cancel': 'Hủy',
      'confirmation': 'Xác nhận xoá',
      'statistics': 'Thống kê',
      'Set Your Budget': 'Đặt ngân sách của bạn',
      'Enter your initial budget': 'Nhập ngân sách ban đầu của bạn',
      'Initial Budget': 'Ngân sách ban đầu',
      'Select Start Date': 'Chọn ngày bắt đầu',
      'Start_date': 'Ngày bắt đầu',
      'Select End Date': 'Chọn ngày kết thúc',
      'End Date': 'Ngày kết thúc',
      'Update Transaction': 'Cập nhật giao dịch',
      'Amount': 'Số tiền',
      'Enter Amount': 'Nhập số tiền',
      'Type: ': 'Loại: ',
      'Expense': 'Chi phí',
      'Income': 'Thu nhập',
      'Tag:': 'Thẻ:',
      'Note:': 'Ghi chú:',
      'Add a note...': 'Thêm ghi chú...',
      'New Transaction': 'Giao dịch mới',
      'AMOUNT:': 'SỐ TIỀN:',
      'TYPE:': 'LOẠI:',
      'TAG:': 'THẺ:',
      'NOTE:': 'GHI CHÚ:',
      'e.g. Bought The End and The Death part 1 from Amazon':
      'ví dụ: Mua The End và The Death phần 1 từ Amazon',
      'Save Transaction': 'Lưu giao dịch',
      'OVER BUDGET!': 'VƯỢT QUÁ NGÂN SÁCH!',
      'Daily Budget': 'Ngân Sách Hôm Nay',
      'Over budget mate!': 'Vượt quá ngân sách bạn ơi!',
      'Days Left:': 'Còn lại:',
      'Start Date:': 'Ngày bắt đầu:',
      'End Date:': 'Ngày kết thúc:',
      'Spending Trend': 'Xu hướng chi tiêu',
      'Spending Category': 'Danh mục chi tiêu',
      'CalenderScreen': 'Lịch sử giao dịch',
      'SelectStartDate' : 'Vui lòng chọn ngày bắt đầu trước',
      'FillCorrectlyWarning': 'Vui lòng nhập đầy đủ thông tin',
      'InvalidAmount': 'Số tiền không hợp lệ',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
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
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
