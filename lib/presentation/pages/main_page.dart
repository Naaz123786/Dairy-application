import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import 'lock_screen.dart';
import '../bloc/diary_bloc.dart';
import '../bloc/reminder_bloc.dart';
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

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 2; // Home is default (Center)
  final LocalDatabase _localDb = GetIt.I<LocalDatabase>();
  late AnimationController _animationController;
  late final StreamSubscription<User?> _authSubscription;
  bool _isAppLocked = false;
  bool _isSectionLocked = false;

  List<Widget> get _pages => [
        const PlannerPage(),
        const CalendarPage(),
        const HomeDashboardPage(),
        DiaryPage(isActive: _currentIndex == 3),
        const ProfilePage(),
      ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addObserver(this);

    // Initial App Lock check
    if (_localDb.isAppLockEnabled() && _localDb.hasDiaryPin()) {
      _isAppLocked = true;
    }

    // Listen to auth changes to refresh the entire app state
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        // Refresh BLoC data on login/logout
        context.read<DiaryBloc>().add(LoadDiaryEntries());
        context.read<ReminderBloc>().add(LoadReminders());
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_localDb.isAppLockEnabled() && _localDb.hasDiaryPin()) {
        setState(() {
          _isAppLocked = true;
        });
      }
    }
  }

  Future<void> _onItemTapped(int index) async {
    if (index == 3 && _localDb.isDiaryLockEnabled() && _localDb.hasDiaryPin()) {
      // Diary Tab with individual lock
      setState(() {
        _isSectionLocked = true;
      });
    } else {
      _animationController.forward(from: 0);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAppLocked) {
      return LockScreen(
        isAppLock: true,
        onUnlocked: () => setState(() => _isAppLocked = false),
      );
    }

    if (_isSectionLocked) {
      return LockScreen(
        isAppLock: false,
        onUnlocked: () {
          _animationController.forward(from: 0);
          setState(() {
            _isSectionLocked = false;
            _currentIndex = 3;
          });
        },
      );
    }

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
