import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'presentation/bloc/diary_bloc.dart';
import 'presentation/bloc/reminder_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DiaryBloc>(create: (_) => di.sl<DiaryBloc>()),
        BlocProvider<ReminderBloc>(
          create: (_) => di.sl<ReminderBloc>()..add(LoadReminders()),
        ),
      ],
      child: MaterialApp(
        title: 'Personal Diary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.home,
      ),
    );
  }
}
