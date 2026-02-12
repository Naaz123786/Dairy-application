import 'package:flutter/material.dart';
import '../../presentation/pages/diary_page.dart';
import '../../presentation/pages/diary_editor_page.dart';
import '../../presentation/pages/calendar_page.dart';
import '../../presentation/pages/planner_page.dart';

import '../../presentation/pages/main_page.dart';
import '../../domain/entities/diary_entry.dart';

import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/onboarding_page.dart';
import '../../presentation/pages/privacy_policy_page.dart';
import '../../presentation/pages/security_settings_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String diary = '/diary';
  static const String diaryEdit = '/diary/edit';
  static const String calendar = '/calendar';
  static const String planner = '/planner';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String privacy = '/privacy';
  static const String security = '/settings/security';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case diary:
        return MaterialPageRoute(builder: (_) => const DiaryPage());
      case diaryEdit:
        final entry = settings.arguments as DiaryEntry?;
        return MaterialPageRoute(builder: (_) => DiaryEditorPage(entry: entry));
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarPage());
      case planner:
        return MaterialPageRoute(builder: (_) => const PlannerPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyPage());
      case security:
        return MaterialPageRoute(builder: (_) => const SecuritySettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
