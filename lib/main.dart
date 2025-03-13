import 'package:budgetbuddy/config/currency_provider.dart';
import 'package:budgetbuddy/config/localization/app_localizations.dart';
import 'package:budgetbuddy/config/localization/locale_provider.dart';
import 'package:budgetbuddy/pages/splash_screen.dart';
import 'package:budgetbuddy/config/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider(isDarkMode)),
      ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ChangeNotifierProvider(create: (context) => CurrencyProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Provider.of<LocaleProvider>(context).locale,
      supportedLocales: const [Locale('en'), Locale('vi')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: SplashScreen(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
