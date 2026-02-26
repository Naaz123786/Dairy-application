import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../domain/repositories/diary_repository.dart';
import '../../domain/repositories/reminder_repository.dart';

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
  bool _authenticatedThisSession = false;

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
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // After login: sync guest data (local) to Firestore so entries are restored
        try {
          await GetIt.I<DiaryRepository>().sync();
          await GetIt.I<ReminderRepository>().sync();
        } catch (e) {
          debugPrint('Sync after login: $e');
        }
      }
      if (mounted) {
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
          _authenticatedThisSession = false; // Reset session on re-lock
        });
      }
    }
  }

  Future<void> _onItemTapped(int index) async {
    final isDiaryTab = index == 3;
    final isGlobalLockActive = _localDb.isAppLockEnabled();
    final isDiaryLockActive = _localDb.isDiaryLockEnabled();

    if (isDiaryTab &&
        !isGlobalLockActive && // Only check individual lock if Global is OFF
        isDiaryLockActive &&
        _localDb.hasDiaryPin() &&
        !_authenticatedThisSession) {
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
        onUnlocked: () => setState(() {
          _isAppLocked = false;
          _authenticatedThisSession = true;
        }),
      );
    }

    if (_isSectionLocked) {
      return LockScreen(
        isAppLock: false,
        onUnlocked: () {
          _animationController.forward(from: 0);
          setState(() {
            _isSectionLocked = false;
            _authenticatedThisSession = true;
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
          color: isDark
              ? const Color(0xFF0D0D0D)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: Colors.cyan.withValues(alpha: isDark ? 0.06 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 72,
            indicatorColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            surfaceTintColor: Colors.transparent,
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
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.45);

    return NavigationDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: inactiveColor,
          size: 24,
        ),
      ),
      selectedIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyan,
              Colors.cyan.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          selectedIcon,
          color: Colors.white,
          size: 22,
        ),
      ),
      label: label,
    );
  }
}
