import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformationModel {
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? username;
  String? userPhone;

  UserRideRequestInformationModel({
    this.destinationLatLng,
    this.originLatLng,
    this.username,
    this.rideRequestId,
    this.destinationAddress,
    this.originAddress,
    this.userPhone,
  });
}
