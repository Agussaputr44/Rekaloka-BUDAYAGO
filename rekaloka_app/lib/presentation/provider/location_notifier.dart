import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../common/failure.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/location/get_addres.dart';
import '../../domain/usecases/location/get_user_location.dart';

class LocationNotifier extends ChangeNotifier {
  final GetUserLocation getUserLocationUseCase;
  final GetAddressFromCoordinates getAddressUseCase; 

  UserLocation? location;
  Failure? failure;
  bool loading = false;
  String? addressName; 

  LocationNotifier(this.getUserLocationUseCase, this.getAddressUseCase); 

  Future<void> fetchLocation() async {
    loading = true;
    failure = null;
    addressName = null;
    notifyListeners();

    final Either<Failure, UserLocation> result =
        await getUserLocationUseCase.execute();

    await result.fold(
      (err) {
        failure = err;
        location = null;
      },
      (loc) async {
        failure = null;
        location = loc;
        
        final addressResult = await getAddressUseCase.execute(loc.latitude, loc.longitude);
        
        addressResult.fold(
          (addrErr) {
             addressName = "Lokasi Tidak Dikenal"; 
          },
          (name) {
             addressName = name; 
          },
        );
      },
    );

    loading = false;
    notifyListeners();
  }
}