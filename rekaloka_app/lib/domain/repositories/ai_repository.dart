import 'package:dartz/dartz.dart';

import '../../common/failure.dart';

abstract class AiRepository {
  Future<Either<Failure,String>> generateImage(String prompt);
}
