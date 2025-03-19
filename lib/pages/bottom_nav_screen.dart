import 'package:budgetbuddy/pages/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'calender_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

/*
* Bottom navigation bar that handles transition between pages.
* */
class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0; // Keep track of which page is currently active
  final logger = Logger();

  /*
  * Function that handles bottom nav item taps,
  * Check if the tapped index is different from the current index.
  * If it is, update the state and navigate to the new page.
  * If it is the same, do nothing.
  * */
  void _navigateBottomBar(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _updateOrientation(index);
      });
    }
  }

  /*
  * Function that handles the orientation of the app.
  * Currently, only Home Screen support both portrait and landscape mode.
  * While all other screens are lock in portrait mode.
  * This is nothing more than a showcase of Responsive layouts.
  * */
  void _updateOrientation(int index) {
    if (index == 0) { // index = 0 is Home Screen.
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  /*
  * This function prevent the app crashing after wiping all data, in Setting Screen,
  * from all tables by resetting the Home Screen variables (e.g. _dailyBudget,
  * _startDate, etc.)to their initial states.
  * */
  _wipeData() {
    try {
      setState(() {
        // Replaces all current Home Screen instances with a new one
        _pages[0] = const HomeScreen();
      });
    } catch (e, stackTrace) {
      logger.e('Error wiping data', error: e, stackTrace: stackTrace);
    }
  }

  // List to hold the widgets for each bottom navigation screen
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const StatisticsScreen(),
      const CalenderScreen(),
      SettingsScreen(
        onDataWipe: _wipeData,
      ),
    ];
    _updateOrientation(_selectedIndex); // Set the initial device orientation
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher( // Used for smooth transition between screen
        duration: const Duration(milliseconds: 500),
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
        // Use a Stack to display/hide a screen based on which _selectedIndex is active
        child: Stack(
          key: ValueKey<int>(_selectedIndex), // Used to trigger a rebuild
          children: _pages.asMap().entries.map((entry) {
            int index = entry.key;
            Widget page = entry.value;
            return Offstage(
              offstage: _selectedIndex != index, // Hides if index is not active
              child: TickerMode(
                enabled: _selectedIndex == index,
                child: page,
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
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

          // calender
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Calender",
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
