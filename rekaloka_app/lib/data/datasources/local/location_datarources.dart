import 'package:geolocator/geolocator.dart';

import '../../../domain/entities/location.dart';

abstract class LocationDataSource {
  Future<UserLocation> getLocation();
}

class LocationDataSourceImpl implements LocationDataSource { 
  @override
  Future<UserLocation> getLocation() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return UserLocation(latitude: pos.latitude, longitude: pos.longitude);
  }
}
