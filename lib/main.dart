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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // For Android/iOS, we rely on google-services.json/GoogleService-Info.plist
    await Firebase.initializeApp();
  }

  await Hive.initFlutter();
  await di.init();

  final localDb = di.sl<LocalDatabase>();
  final initialRoute =
      localDb.isOnboardingComplete() ? AppRoutes.home : AppRoutes.onboarding;

  runApp(MyApp(initialRoute: initialRoute));
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
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Personal Diary',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: initialRoute,
          );
        },
      ),
    );
  }
}
