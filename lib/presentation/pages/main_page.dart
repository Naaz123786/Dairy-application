import 'package:flutter/material.dart';
import '../../core/security/security_service.dart';
import '../../core/theme/app_theme.dart';
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

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 2; // Home is default (Center)
  final SecurityService _securityService = GetIt.I<SecurityService>();
  late AnimationController _animationController;

  final List<Widget> _pages = const [
    PlannerPage(),
    CalendarPage(),
    HomeDashboardPage(),
    DiaryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 3) {
      // Diary Tab
      bool isAuthenticated = await _securityService.authenticate();
      if (isAuthenticated) {
        _animationController.forward(from: 0);
        setState(() {
          _currentIndex = index;
        });
      }
    } else {
      _animationController.forward(from: 0);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.black : AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[900]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 70,
            indicatorColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              _buildNavDestination(
                icon: Icons.calendar_view_day_outlined,
                selectedIcon: Icons.calendar_view_day,
                label: 'Planner',
                index: 0,
                isDark: isDark,
              ),
              _buildNavDestination(
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month,
                label: 'Calendar',
                index: 1,
                isDark: isDark,
              ),
              _buildNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                index: 2,
                isDark: isDark,
              ),
              _buildNavDestination(
                icon: Icons.book_outlined,
                selectedIcon: Icons.book,
                label: 'Diary',
                index: 3,
                isDark: isDark,
              ),
              _buildNavDestination(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
                index: 4,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? AppTheme.white : AppTheme.black;
    final inactiveColor = Colors.grey;

    return NavigationDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? activeColor : inactiveColor,
          size: 24,
        ),
      ),
      selectedIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: activeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          selectedIcon,
          color: isDark ? AppTheme.black : AppTheme.white,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}
