import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http; // Asumsi: Menggunakan http.Client
import 'presentation/provider/auth_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Data Layer
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/local/token_local_datasource.dart';
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
  // A. EXTERNAL / CORE UTILITIES (PALING DASAR)
  // =======================================================
  // 1. HTTP Client
  // Ini adalah objek 'Client' yang error cari sebelumnya. Harus didaftarkan duluan.
  sl.registerLazySingleton(() => http.Client());
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  
  // =======================================================
  // B. DATA SOURCES (Mendukung Repository)
  // =======================================================
  // 2. Token Local Data Source (Harus ada implementasi!)
  sl.registerLazySingleton<TokenLocalDataSource>(
    // Ganti dengan implementasi actual Anda, misalnya TokenLocalDataSourceImpl(sharedPreferences: sl())
    () => TokenLocalDataSourceImpl(prefs: sharedPreferences), 
  );

  // 3. Remote Data Source (Membutuhkan Client & TokenLocalDataSource)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl(), tokenLocalDataSource: sl()),
  );

  // =======================================================
  // C. REPOSITORY (Mendukung Use Cases)
  // =======================================================
  // 4. Auth Repository (Membutuhkan Remote & Local Data Source)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenLocalDataSource: sl()),
  );

  // =======================================================
  // D. USE CASES (Mendukung Notifier)
  // =======================================================
  // 5. Use Cases (Membutuhkan AuthRepository)
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));

  // =======================================================
  // E. NOTIFIER (Layer Presentasi)
  // =======================================================
  // 6. Auth Notifier (Membutuhkan semua Use Cases)
  sl.registerFactory(
    () => AuthNotifier(
      loginUseCase: sl(),
      registerUseCase: sl(),
      verifyEmailUseCase: sl(),
      getUserProfileUseCase: sl(),
    ),
  );
}