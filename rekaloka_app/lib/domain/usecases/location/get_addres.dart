import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../../repositories/location_repository.dart';

class GetAddressFromCoordinates {
  final LocationRepository repository;
  GetAddressFromCoordinates(this.repository);
  Future<Either<Failure, String>> execute(double latitude, double longitude) {
    return repository.getAddressFromCoordinates(latitude, longitude);
  }
}
