import 'package:get_it/get_it.dart';
import 'package:rekaloka_app/data/datasources/auth_remote_datasource.dart';
import 'package:rekaloka_app/data/repositories/auth_repository_impl.dart';
import 'package:rekaloka_app/domain/repositories/auth_repository.dart';
import 'package:rekaloka_app/domain/usecases/auth/get_user_profile.dart';
import 'package:rekaloka_app/domain/usecases/auth/login.dart';
import 'package:rekaloka_app/domain/usecases/auth/register.dart';
import 'package:rekaloka_app/domain/usecases/auth/verify_email.dart';

final sl = GetIt.instance;
Future<void> init() async {
  
  // ===Auth===
  // ---UseCases---
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => VerifyEmail(sl()));
  // ---DataSource & Repository---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl(), tokenLocalDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(remoteDataSource: sl(), tokenLocalDataSource: sl()),
  );
}
