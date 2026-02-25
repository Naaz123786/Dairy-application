import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/bloc/diary_bloc.dart';
import 'presentation/bloc/reminder_bloc.dart';
import 'presentation/bloc/theme_cubit.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/datasources/local_database.dart';
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

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.init();

    // Reschedule daily reminder if enabled
    if (localDb.isDailyReminderEnabled()) {
      await notificationService.scheduleDailyReminder();
    }

    final initialRoute =
        localDb.isOnboardingComplete() ? AppRoutes.home : AppRoutes.onboarding;

    runApp(MyApp(initialRoute: initialRoute));
  }, (error, stack) {
    debugPrint('Startup Error: $error');
    debugPrint(stack.toString());
  });
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
            title: 'Personal Diary',
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
