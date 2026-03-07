import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/bloc/diary_bloc.dart';
import 'presentation/bloc/reminder_bloc.dart';
import 'presentation/bloc/theme_cubit.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/datasources/local_database.dart';
import 'domain/repositories/reminder_repository.dart';
import 'presentation/widgets/theme_background.dart';
import 'core/services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }

    await Hive.initFlutter();
    await di.init();

    final localDb = di.sl<LocalDatabase>();

    // Initialize notification service (and timezone for scheduled notifications)
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();

    // Awesome Notifications: set listeners (required for scheduled notifications)
    if (!kIsWeb) {
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
      );
    }

    // Reschedule daily reminder if enabled
    if (localDb.isDailyReminderEnabled()) {
      await notificationService.scheduleDailyReminder();
    }

    // Reschedule exam & birthday notifications on every app start (survives reboot/kill)
    try {
      await di.sl<ReminderRepository>().getReminders();
    } catch (e) {
      debugPrint('Startup reminder reschedule: $e');
    }

    final initialRoute =
        localDb.isOnboardingComplete() ? AppRoutes.home : AppRoutes.onboarding;

    runApp(PersistenceWrapper(child: MyApp(initialRoute: initialRoute)));
  }, (error, stack) {
    debugPrint('Startup Error: $error');
    debugPrint(stack.toString());
  });
}

/// Flushes Hive boxes to disk when app goes to background so data persists after close.
class PersistenceWrapper extends StatefulWidget {
  const PersistenceWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<PersistenceWrapper> createState() => _PersistenceWrapperState();
}

class _PersistenceWrapperState extends State<PersistenceWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Flush Hive to disk when app goes to background so data persists after close
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      di.sl<LocalDatabase>().flushBoxes();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DiaryBloc>(
          create: (_) => di.sl<DiaryBloc>()..add(LoadDiaryEntries()),
        ),
        BlocProvider<ReminderBloc>(
          create: (_) => di.sl<ReminderBloc>()..add(LoadReminders()),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(di.sl<LocalDatabase>()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, String>(
        builder: (context, themeKey) {
          final themeData = AppTheme.getTheme(themeKey);
          return MaterialApp(
            title: 'My Diary',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: initialRoute,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('hi', 'IN'),
            ],
            builder: (context, child) {
              return ThemeBackground(child: child!);
            },
          );
        },
      ),
    );
  }
}

/// Awesome Notifications event handlers (required by plugin).
class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {}

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {}
}
