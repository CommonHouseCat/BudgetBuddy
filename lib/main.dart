import 'package:budgetbuddy/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;
import 'package:shared_preferences/shared_preferences.dart';
import 'config/currency_provider.dart';
import 'config/localization/app_localizations.dart';
import 'config/localization/locale_provider.dart';
import 'config/themes/theme_provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized before interacting with the Flutter engine.
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode)),
      ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
      theme: Provider.of<ThemeProvider>(context).themeData,
      //List manages app localization
      localizationsDelegates: const [
        AppLocalizationsDelegate(), // Custom delegate for app-specific translations
        GlobalMaterialLocalizations
            .delegate, // Handles Material widget translations (buttons, dialogs, etc.)
        GlobalWidgetsLocalizations
            .delegate, // Sets text direction (LTR/RTL) and basic widget localization
        GlobalCupertinoLocalizations
            .delegate, // Handles Cupertino (iOS-style) widget translations
      ],
      home: SplashScreen(),
    );
  }
}
