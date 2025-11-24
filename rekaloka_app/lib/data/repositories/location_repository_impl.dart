import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart'; 
import 'package:geolocator/geolocator.dart';
import '../datasources/local/location_datarources.dart';

import '../../common/failure.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource datasource;

  LocationRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, UserLocation>> getUserLocation() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        return const Left(
          ServiceDisabledFailure("Location services are disabled."),
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(
            PermissionFailure("Location permission denied."),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const Left(
          PermissionFailure("Location permission permanently denied."),
        );
      }

      final location = await datasource.getLocation();
      return Right(location);
    } catch (e) {
      return Left(
        LocationFailure("Failed to get location: $e"),
      );
    }
  }

  @override
  Future<Either<Failure, String>> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        
        final city = placemark.locality ?? placemark.subAdministrativeArea;
        final province = placemark.administrativeArea;
        
        String address = "";
        if (city != null && province != null) {
          address = "$city, $province";
        } else if (province != null) {
          address = province;
        } else {
          address = "Lokasi Tidak Dikenal";
        }

        return Right(address);
      } else {
        return const Left(
          LocationFailure("No address found for the given coordinates."),
        );
      }
    } catch (e) {
      return Left(
        LocationFailure("Failed to get address: $e"),
      );
    }
  }
}