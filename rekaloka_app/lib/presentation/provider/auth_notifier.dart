import 'package:flutter/foundation.dart';
import '../../common/state.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';
import '../../domain/usecases/auth/verify_email.dart';
import '../../domain/usecases/auth/get_user_profile.dart';
import '../../domain/entities/user.dart';

typedef AuthState = RequestState;

class AuthNotifier extends ChangeNotifier {
  final Login loginUseCase;
  final Register registerUseCase;
  final VerifyEmail verifyEmailUseCase;
  final GetUserProfile getUserProfileUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyEmailUseCase,
    required this.getUserProfileUseCase,
  });

  User? _user;
  AuthState _authState = RequestState.Empty;
  String _message = '';

  User? get user => _user;
  AuthState get authState => _authState;
  String get message => _message;

  Future<void> registerUser(String email, String password, String name) async {
    _authState = RequestState.Loading;
    _message = '';
    notifyListeners();

    final result = await registerUseCase.execute(email, password, name);

    result.fold(
      (failure) {
        _message = failure.message;
        _authState = RequestState.Error;
      },
      (userEntity) {
        _authState = RequestState.Loaded;
      },
    );
    notifyListeners();
  }

  Future<void> loginUser(String email, String password) async {
    _authState = RequestState.Loading;
    _message = '';
    notifyListeners();

    final result = await loginUseCase.execute(email, password);

    result.fold(
      (failure) {
        _message = failure.message;
        _authState = RequestState.Error;
      },
      (userEntity) {
        _user = userEntity;
        _authState = RequestState.Loaded;
      },
    );
    notifyListeners();
  }

  Future<void> verifyUserEmail(String email, String code) async {
    _authState = RequestState.Loading;
    _message = '';
    notifyListeners();

    final result = await verifyEmailUseCase.execute(email, code);

    result.fold(
      (failure) {
        _message = failure.message;
        _authState = RequestState.Error;
      },
      (_) {
        _message = "Verifikasi email berhasil!";
        _authState = RequestState.Loaded;
      },
    );
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    _authState = RequestState.Loading;
    _message = '';
    notifyListeners();

    final result = await getUserProfileUseCase.execute();

    result.fold(
      (failure) {
        _message = 'Gagal memuat profil: ${failure.message}';
        _authState = RequestState.Error;
        _user = null;
      },
      (userEntity) {
        _user = userEntity;
        _authState = RequestState.Loaded;
      },
    );

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _authState = RequestState.Loading;
    notifyListeners();

    final result = await getUserProfileUseCase.execute();

    result.fold(
      (failure) {
        _authState = RequestState.Empty; 
        _user = null;
      },
      (userEntity) {
        _user = userEntity;
        _authState = RequestState.Loaded; 
      },
    );
    notifyListeners();
  }

  void resetAuthState() {
    _authState = RequestState.Empty; 
    _message = '';
  }

  void logout() {
    _user = null;
    _authState = RequestState.Empty;
    _message = '';
    notifyListeners();
  }
}
