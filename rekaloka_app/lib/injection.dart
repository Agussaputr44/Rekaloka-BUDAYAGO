import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:rekaloka_app/data/datasources/ai_remote_datasource.dart';
import 'package:rekaloka_app/data/datasources/local/location_datarources.dart';
import 'package:rekaloka_app/domain/usecases/location/get_addres.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AUTH
import 'package:rekaloka_app/domain/usecases/auth/get_token_user.dart';
import 'package:rekaloka_app/domain/usecases/auth/remember_me.dart';
import 'package:rekaloka_app/domain/usecases/auth/save_token_user.dart';
import 'presentation/provider/auth_notifier.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth/get_user_profile.dart';
import 'domain/usecases/auth/login.dart';
import 'domain/usecases/auth/register.dart';
import 'domain/usecases/auth/verify_email.dart';

// LOCATION
import 'package:rekaloka_app/domain/usecases/location/get_user_location.dart';
import 'package:rekaloka_app/presentation/provider/location_notifier.dart';
import 'package:rekaloka_app/data/repositories/location_repository_impl.dart';
import 'package:rekaloka_app/domain/repositories/location_repository.dart';

// AI (BARU)
import 'package:rekaloka_app/data/repositories/ai_repository_impl.dart';
import 'package:rekaloka_app/domain/repositories/ai_repository.dart';
import 'package:rekaloka_app/domain/usecases/ai/text_to_image.dart';
import 'package:rekaloka_app/presentation/provider/ai_notifier.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =======================================================
  // A. EXTERNAL
  // =======================================================
  sl.registerLazySingleton(() => http.Client());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // =======================================================
  // B. AUTH DATA SOURCES
  // =======================================================
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(prefs: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl(), authLocalDatasource: sl()),
  );

  // =======================================================
  // C. AUTH REPOSITORY
  // =======================================================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), authLocalDatasource: sl()),
  );

  // =======================================================
  // D. AUTH USE CASES
  // =======================================================
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));
  sl.registerLazySingleton(() => GetTokenUser(sl()));
  sl.registerLazySingleton(() => SaveTokenUser(sl()));
  sl.registerLazySingleton(() => RememberMe(sl()));

  // =======================================================
  // E. AUTH NOTIFIER
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

  // =======================================================
  // F. LOCATION DATA SOURCES
  // =======================================================
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());

  // =======================================================
  // G. LOCATION REPOSITORY
  // =======================================================
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(sl()),
  );

  // =======================================================
  // H. LOCATION USE CASES
  // =======================================================
  sl.registerLazySingleton(() => GetUserLocation(sl()));
  sl.registerLazySingleton(() => GetAddressFromCoordinates(sl()));

  // =======================================================
  // I. LOCATION NOTIFIER
  // =======================================================
  sl.registerFactory(() => LocationNotifier(sl(), sl()));

  // =======================================================
  // J. AI DATA SOURCES (BARU)
  // =======================================================
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(client: sl(), authLocalDatasource: sl()),
  );

  // =======================================================
  // K. AI REPOSITORY (BARU)
  // =======================================================
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(remoteDataSource: sl(), authLocalDatasource: sl()),
  );

  // =======================================================
  // L. AI USE CASES (BARU)
  // =======================================================
  sl.registerLazySingleton(() => TextToImage(sl()));

  // =======================================================
  // M. AI NOTIFIER (BARU)
  // =======================================================
  sl.registerFactory(() => AiNotifier(textToImageUseCase: sl()));
}
