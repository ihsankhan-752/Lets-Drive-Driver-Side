import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_drive_driver_side/assistants/request_assistant.dart';
import 'package:provider/provider.dart';

import '../global/globals.dart';
import '../global/map_key.dart';
import '../info_handler/app_info.dart';
import '../models/direction_details_model.dart';
import '../models/directions.dart';
import '../models/history_model.dart';
import '../models/user_model.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModel = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

//=====================To SEE USER LOCATION IN READABLE FORM========================//
  static Future<String> getLocationFromApiInHumanReadableForm(Position position, BuildContext context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapApiKey";
    String humanReadableAddress = '';
    var response = await RequestAssistant.receiveRequest(apiUrl);
    if (response != "Failed") {
      humanReadableAddress = response['results'][0]['formatted_address'];
      DirectionModel userPickUpAddress = DirectionModel();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  //=======================Function For Direction Api Which Required Two Parameters Latlng of Origin and Latlang of Destination======================//

  static Future<DirectionDetailInfo?> obtainOriginToDestinationDirectionsDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapApiKey";

    var response = await RequestAssistant.receiveRequest(url);

    if (response == "Failed") {
      return null;
    }
    DirectionDetailInfo directionDetailInfo = DirectionDetailInfo();

    directionDetailInfo.e_points = response['routes'][0]['overview_polyline']['points'];
    directionDetailInfo.distance_text = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetailInfo.distance_value = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetailInfo.duration_text = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetailInfo.duration_value = response['routes'][0]['legs'][0]['duration']['value'];
//we return this because we need it in main screen
    return directionDetailInfo;
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates() {
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(
      currentFirebaseUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.1;

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;

    if (driverVehicleType == "bike") {
      double resultFairAmount = (totalFareAmount.truncate()) / 2;
      return resultFairAmount;
    } else if (driverVehicleType == "uber-go") {
      return totalFareAmount.truncate().toDouble();
    } else if (driverVehicleType == "uber-x") {
      double resultFairAmount = (totalFareAmount.truncate()) * 2;
      return resultFairAmount;
    } else {
      return totalFareAmount.truncate().toDouble();
    }
  }

  //trip key mean ride request keys
  //retrieve trip keys for online user
  static void readTripKeysForOnlineDrivers(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(fAuth.currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total numbers of trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider

        List<String> tripsKeysList = [];

        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripKeys(tripsKeysList);

        //get trips keys data

        readTripsHistoryInformation(context);
      }
    });
  }

  static readTripsHistoryInformation(BuildContext context) {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripKeysList;

    for (String getEachKey in tripsAllKeys) {
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(getEachKey).once().then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);
        //updating overall trips history
        if ((snap.snapshot.value as Map)['status'] == "ended") {
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

  //readDriverEarnings

  static readDriverEarnings(BuildContext context) async {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);
      }
    });
    readTripKeysForOnlineDrivers(context);
  }

  static readDriversRating(context) async {
    FirebaseDatabase.instance.ref().child("drivers").child(fAuth.currentUser!.uid).child("ratings").once().then((snap) {
      if (snap.snapshot.value != null) {
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverAverageRatings(driverRatings);
      }
    });
  }
}
