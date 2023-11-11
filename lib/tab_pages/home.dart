import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistants_methods.dart';
import '../global/globals.dart';
import '../push_notifications/push_notification_system.dart';
import '../widgets/custom_msg.dart';
import '../widgets/map_black_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //in course its name is _controllerGoogleMap
  final Completer<GoogleMapController> _controller = Completer();
  //in course this name is newGoogleMapController
  GoogleMapController? googleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = position;

    LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 14);
    googleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress =
        await AssistantMethods.getLocationFromApiInHumanReadableForm(driverCurrentPosition!, context);

    AssistantMethods.readDriversRating(context);
  }

  readCurrentDriverInformation() {
    currentFirebaseUser = fAuth.currentUser;

    FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).once().then((snap) {
      if (snap.snapshot.value != null) {
        onlineDriverData.id = (snap.snapshot.value as Map)['id'];
        onlineDriverData.name = (snap.snapshot.value as Map)['name'];
        onlineDriverData.phone = (snap.snapshot.value as Map)['phone'];
        onlineDriverData.email = (snap.snapshot.value as Map)['email'];
        onlineDriverData.car_color = (snap.snapshot.value as Map)['car_details']['car_color'];
        onlineDriverData.car_model = (snap.snapshot.value as Map)['car_details']['car_model'];
        onlineDriverData.car_number = (snap.snapshot.value as Map)['car_details']['car_number'];
        driverVehicleType = (snap.snapshot.value as Map)['car_details']['type'];
      } else {
        showCustomMsg(context, "No Online Driver Found");
      }
    });
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.getToken();

    AssistantMethods.readDriverEarnings(context);
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              googleMapController = controller;
              googleMapController!.setMapStyle(mapBlackTheme);
              locateDriverCurrentPosition();
            },
          ),

          //making UI for Online and Offline Driver
          statusText != "Now Online"
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Colors.black87,
                )
              : SizedBox(),

          // Button for making driver online and offline

          Positioned(
            top: statusText != "Now Online" ? MediaQuery.of(context).size.height * 0.4 : 55,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (isDriverActive != true) {
                      //offline
                      driverIsOnlineNow();
                      updateDriversLocationAtRealTime();
                      setState(() {
                        statusText = "Now Online";
                        isDriverActive = true;
                        buttonColor = Colors.transparent;
                      });

                      showCustomMsg(context, "You are Now Online");
                    } else {
                      driverIsOfflineNow();
                      setState(() {
                        statusText = "Now Offline";
                        isDriverActive = false;
                        buttonColor = Colors.grey;
                      });
                      showCustomMsg(context, "You are Now Offline");
                    }

                    // setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: statusText != "Now Online"
                      ? Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.phonelink_ring, color: Colors.white, size: 26),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  driverIsOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    driverCurrentPosition = position;
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(
      currentFirebaseUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    ref.set("idle"); //mean searching for ride request
    ref.onValue.listen((event) {});
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((position) {
      driverCurrentPosition = position;

      if (isDriverActive == true) {
        Geofire.setLocation(
          currentFirebaseUser!.uid,
          driverCurrentPosition!.latitude,
          driverCurrentPosition!.longitude,
        );
      }
      LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      googleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref =
        FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("newRideStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;
    Future.delayed(Duration(seconds: 2), () {
      SystemNavigator.pop();
    });
  }
}
