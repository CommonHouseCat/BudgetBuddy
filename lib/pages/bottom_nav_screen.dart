import 'package:budgetbuddy/config/localization/locale_provider.dart';
import 'package:budgetbuddy/pages/home_screen.dart';
import 'package:budgetbuddy/pages/settings_screen.dart';
import 'package:budgetbuddy/pages/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeLanguageFromSettings(Locale newLocale) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(newLocale);
  }

  _wipeData() {
    setState(() {
      _pages[0] = const HomeScreen();
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const StatisticsScreen(),
      SettingsScreen(
        onLanguageChange: _changeLanguageFromSettings,
        onDataWipe: _wipeData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: child,
          );
        },
        child: Stack(
          key: ValueKey<int>(_selectedIndex),
          children: _pages.asMap().entries.map((entry) {
            int index = entry.key;
            Widget page = entry.value;
            return Offstage(
              offstage: _selectedIndex != index,
              child: TickerMode(
                enabled: _selectedIndex == index,
                child: page,
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          // home
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          // statistic
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Statistics",
          ),

          // settings
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

}
