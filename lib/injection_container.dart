import 'package:get_it/get_it.dart';
import 'core/security/security_service.dart';
import 'data/datasources/local_database.dart';
import 'data/datasources/firestore_database.dart';
import 'data/repositories/diary_repository_impl.dart';
import 'data/repositories/diary_repository_firestore_impl.dart';
import 'domain/repositories/diary_repository.dart';
import 'presentation/bloc/diary_bloc.dart';
import 'core/services/notification_service.dart';
import 'presentation/bloc/reminder_bloc.dart';
import 'data/repositories/reminder_repository_impl.dart';
import 'domain/repositories/reminder_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Diary
  // Bloc
  sl.registerFactory(() => DiaryBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<DiaryRepository>(
    () => DiaryRepositoryFirestoreImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton(() => FirestoreDatabase());
  sl.registerLazySingleton(() => LocalDatabase());
  sl.registerLazySingleton(() => SecurityService());
  sl.registerLazySingleton(() => NotificationService());

  // Features - Reminders
  sl.registerFactory(() => ReminderBloc(repository: sl()));
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(sl(), sl()),
  );

  //! External
  await sl<LocalDatabase>().init();
  await sl<NotificationService>().init();
  await sl<NotificationService>().requestPermissions();
}
