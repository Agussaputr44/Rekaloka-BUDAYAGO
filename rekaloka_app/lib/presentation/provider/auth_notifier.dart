import 'package:flutter/foundation.dart';
import 'package:rekaloka_app/domain/usecases/auth/get_token_user.dart';
import 'package:rekaloka_app/domain/usecases/auth/save_token_user.dart';
import '../../common/state.dart';
import '../../domain/usecases/auth/login.dart';
import '../../domain/usecases/auth/register.dart';
import '../../domain/usecases/auth/remember_me.dart';
import '../../domain/usecases/auth/verify_email.dart';
import '../../domain/usecases/auth/get_user_profile.dart';
import '../../domain/entities/user.dart';

typedef AuthState = RequestState;

class AuthNotifier extends ChangeNotifier {
  final Login loginUseCase;
  final Register registerUseCase;
  final VerifyEmail verifyEmailUseCase;
  final GetUserProfile getUserProfileUseCase;
  final GetTokenUser getTokenUseCase;
  final SaveTokenUser saveTokenUseCase;
  final RememberMe rememberMeUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyEmailUseCase,
    required this.getUserProfileUseCase,
    required this.getTokenUseCase,
    required this.saveTokenUseCase,
    required this.rememberMeUseCase,
  });

  User? _user;
  AuthState _authState = RequestState.Empty;
  String _message = '';
  bool _isRegisterSuccess = false;
  bool _rememberMe = false;
  String? _rememberedEmail;

  User? get user => _user;
  AuthState get authState => _authState;
  String get message => _message;
  bool get isRegisterSuccess => _isRegisterSuccess;
  bool get rememberMe => _rememberMe;
  String? get rememberedEmail => _rememberedEmail;

  Future<void> registerUser(String email, String password, String name) async {
    _authState = RequestState.Loading;
    _message = '';
    _isRegisterSuccess = true;
    notifyListeners();

    final result = await registerUseCase.execute(email, password, name);

    result.fold(
      (failure) {
        _message = failure.message;
        _authState = RequestState.Error;
        _isRegisterSuccess = false;
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
    _isRegisterSuccess = false;
    notifyListeners();

    final result = await loginUseCase.execute(email, password);

    await result.fold(
      (failure) async {
        _message = failure.message;
        _authState = RequestState.Error;
      },
      (userEntity) async {
        _user = userEntity;
        _authState = RequestState.Loaded;
        _isRegisterSuccess = false;
        final saveRememberResult = await rememberMeUseCase.saveRememberMe(
          email,
          _rememberMe,
        );
        saveRememberResult.fold(
          (failure) => print(
            'Warning: Gagal menyimpan Remember Me status: ${failure.message}',
          ),
          (_) => null,
        );
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

    final tokenResult = await getTokenUseCase.execute();

    if (tokenResult.isLeft()) {
      _authState = RequestState.Empty;
      _user = null;
      notifyListeners();
      return;
    }

    final tokenString = tokenResult.getOrElse(() => null);

    if (tokenString == null || tokenString.isEmpty) {
      _authState = RequestState.Empty;
      _user = null;
      notifyListeners();
      return;
    }

    final userProfileResult = await getUserProfileUseCase.execute();

    userProfileResult.fold(
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

  Future<void> _loadRememberMeStatus() async {
    final result = await rememberMeUseCase.getRememberMeStatus();

    result.fold(
      (failure) {
      },
      (data) {
        _rememberMe = data['status'] as bool;
        _rememberedEmail = data['email'] as String?;
      },
    );
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void resetAuthState() {
    _authState = RequestState.Empty;
    _message = '';
    _isRegisterSuccess = false;
  }

  void logout() {
    _user = null;
    _authState = RequestState.Empty;
    _message = '';
    notifyListeners();
  }
}
