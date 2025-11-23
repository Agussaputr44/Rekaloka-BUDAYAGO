import 'package:dartz/dartz.dart';

import '../../common/failure.dart';
import '../entities/location.dart';

abstract class LocationRepository {
  Future<Either<Failure, UserLocation>> getUserLocation();
  Future<Either<Failure, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  );
}
