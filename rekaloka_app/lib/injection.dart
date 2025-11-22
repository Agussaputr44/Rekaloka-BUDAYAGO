import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http; // Asumsi: Menggunakan http.Client
import 'package:rekaloka_app/domain/usecases/auth/get_token_user.dart';
import 'package:rekaloka_app/domain/usecases/auth/remember_me.dart';
import 'package:rekaloka_app/domain/usecases/auth/save_token_user.dart';
import 'presentation/provider/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Data Layer
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';

// Import Domain Layer
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth/get_user_profile.dart';
import 'domain/usecases/auth/login.dart';
import 'domain/usecases/auth/register.dart';
import 'domain/usecases/auth/verify_email.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =======================================================
  // A. EXTERNAL / CORE UTILITIES
  // =======================================================
  sl.registerLazySingleton(() => http.Client());
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  // =======================================================
  // B. DATA SOURCES
  // =======================================================
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(prefs: sharedPreferences),
  );

  // 3. Remote Data Source (
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl(), authLocalDatasource: sl()),
  );

  // =======================================================
  // C. REPOSITORY
  // =======================================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), authLocalDatasource: sl()),
  );

  // =======================================================
  // D. USE CASES (Mendukung Notifier)
  // =======================================================
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));
  sl.registerLazySingleton(() => GetTokenUser(sl()));
  sl.registerLazySingleton(() => SaveTokenUser(sl()));
  sl.registerLazySingleton(() => RememberMe(sl()));

  // =======================================================
  // E. NOTIFIER (Layer Presentasi)
  // =======================================================
  sl.registerFactory(
    () => AuthNotifier(
      loginUseCase: sl(),
      registerUseCase: sl(),
      verifyEmailUseCase: sl(),
      getUserProfileUseCase: sl(),
      getTokenUseCase: sl(),
      saveTokenUseCase: sl(),
      rememberMeUseCase: sl(),
    ),
  );
}
