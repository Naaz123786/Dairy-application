import 'package:flutter/material.dart';
import '../../core/security/security_service.dart';
import 'planner_page.dart';
import 'calendar_page.dart';
import 'diary_page.dart';
import 'home_dashboard_page.dart';
import 'profile_page.dart';
import 'package:get_it/get_it.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 2; // Home is default (Center)
  final SecurityService _securityService = GetIt.I<SecurityService>();

  final List<Widget> _pages = const [
    PlannerPage(),
    CalendarPage(),
    HomeDashboardPage(),
    DiaryPage(),
    ProfilePage(),
  ];

  Future<void> _onItemTapped(int index) async {
    if (index == 3) {
      // Diary Tab (Index 3 now)
      bool isAuthenticated = await _securityService.authenticate();
      if (isAuthenticated) {
        setState(() {
          _currentIndex = index;
        });
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          indicatorColor: Theme.of(context).primaryColor.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_view_day_outlined),
              selectedIcon: Icon(Icons.calendar_view_day),
              label: 'Planner',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Diary',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
