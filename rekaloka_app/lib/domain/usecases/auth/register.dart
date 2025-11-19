import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../../common/failure.dart';
// Hapus import User Entity dari sini

class Register {
  final AuthRepository repository;

  Register(this.repository);

  // DIUBAH: Sekarang mengembalikan Future<Either<Failure, void>>
  Future<Either<Failure, void>> execute(
    String email,
    String password,
    String name,
  ) {
    // Memanggil method register yang baru di Repository
    return repository.register(email, password, name);
  }
}