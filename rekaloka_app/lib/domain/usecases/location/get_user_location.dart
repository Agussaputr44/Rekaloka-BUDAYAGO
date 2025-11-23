import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../../entities/location.dart';
import '../../repositories/location_repository.dart';

class GetUserLocation {
  final LocationRepository repository;

  GetUserLocation(this.repository);

  Future<Either<Failure, UserLocation>> execute() async {
    return repository.getUserLocation();
  }
}
