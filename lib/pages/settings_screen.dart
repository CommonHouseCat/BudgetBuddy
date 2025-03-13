import 'package:budgetbuddy/components/confirmation_dialog.dart';
import 'package:budgetbuddy/components/my_buttons.dart';
import 'package:budgetbuddy/config/localization/app_localizations.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/config/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgetbuddy/config/currency_provider.dart';
import 'package:budgetbuddy/config/localization/locale_provider.dart';

class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  final VoidCallback onDataWipe;

  const SettingsScreen({
    super.key,
    required this.onLanguageChange,
    required this.onDataWipe,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    Future<void> wipeData() async {
      await DatabaseService.instance.deleteUserBudget();
      await DatabaseService.instance.deleteTransactionTable();
      widget.onDataWipe();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate("data_wipe_message")),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    void confirmDeletionDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationDialog(
            onCancel: () => Navigator.of(context).pop(),
            onConfirm: wipeData,
            titleText: localizations.translate("confirm_wipe"),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(localizations.translate('settings')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dark mode toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(25.0),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizations.translate("dark_mode")),
                  // const Text("Dart Mode"),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                  )
                ],
              ),
            ),

            // Language selector
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(25.0),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizations.translate("language")),
                  DropdownButton<Locale>(
                    value: localeProvider.locale,
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: Locale('vi'),
                        child: Text('Tiếng Việt'),
                      ),
                    ],
                    onChanged: (value) {
                      localeProvider.setLocale(value!);
                    },
                  ),
                ],
              ),
            ),

            // Currency selector
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(25.0),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizations.translate("currency")),
                  DropdownButton<String>(
                    value: currencyProvider.currencySymbol,
                    items: const [
                      DropdownMenuItem(
                        value: '\$',
                        child: Text('USD (\$)'),
                      ),
                      DropdownMenuItem(
                        value: '₫',
                        child: Text('VND (₫)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        currencyProvider.setCurrencySymbol(value);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Delete all data button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(25.0),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizations.translate("data_wipe")),
                  MyButtons(
                    text: "Wipe",
                    onPressed: confirmDeletionDialog,
                    buttonColor: Colors.red,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),

            // About app section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.all(25.0),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: localizations.translate("about_app"),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.info_outline,
                              size: 16,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(localizations.translate("app_description")),
                  SizedBox(height: 8),
                  Text(localizations.translate("app_version")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
