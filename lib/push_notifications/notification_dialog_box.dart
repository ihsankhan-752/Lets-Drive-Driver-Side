import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assistants/assistants_methods.dart';
import '../global/globals.dart';
import '../main_screen/new_trip_screen.dart';
import '../models/user_ride_request_information_model.dart';
import '../widgets/custom_msg.dart';

class NotificationDialogBox extends StatefulWidget {
  final UserRideRequestInformationModel? userRideRequestDetails;
  const NotificationDialogBox({Key? key, this.userRideRequestDetails}) : super(key: key);

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Image.asset(
              "images/car_logo.png",
              width: 200,
            ),
            SizedBox(height: 8),
            Text(
              "New Ride Request",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(height: 3, thickness: 3),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("images/origin.png", width: 30, height: 30),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Image.asset("images/destination.png", width: 30, height: 30),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(height: 3, thickness: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    //cancel the rideRequest
                    audioPlayer.pause();
                    audioPlayer.stop();
                    audioPlayer = AssetsAudioPlayer();

                    FirebaseDatabase.instance
                        .ref()
                        .child("All Ride Requests")
                        .child(widget.userRideRequestDetails!.rideRequestId!)
                        .remove()
                        .then((value) {
                      FirebaseDatabase.instance
                          .ref()
                          .child("drivers")
                          .child(currentFirebaseUser!.uid)
                          .child("newRideStatus")
                          .set("idle");
                    }).then((value) {
                      FirebaseDatabase.instance
                          .ref()
                          .child("drivers")
                          .child(currentFirebaseUser!.uid)
                          .child("tripsHistory")
                          .child(widget.userRideRequestDetails!.rideRequestId!)
                          .remove();
                    }).then((value) {
                      showCustomMsg(context, "Ride Request has been cancel successfully");
                    });
                    Future.delayed(Duration(seconds: 3), () {
                      SystemNavigator.pop();
                    });
                  },
                  child: Text(
                    "Cancel".toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    //cancel the rideRequest
                    audioPlayer.pause();
                    audioPlayer.stop();
                    audioPlayer = AssetsAudioPlayer();
                    // Navigator.pop(context);
                    acceptRideRequest(context);
                  },
                  child: Text(
                    "Accept".toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    String getRideRequestId = '';
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child('newRideStatus')
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        getRideRequestId = snap.snapshot.value.toString();
      } else {
        showCustomMsg(context, "This Ride Request Do not Exist");
      }

      //todo here we will convert the below hardcoded value to getRideRequestId
      if (getRideRequestId == widget.userRideRequestDetails!.rideRequestId) {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child('newRideStatus')
            .set("accepted");

        AssistantMethods.pauseLiveLocationUpdates();
        //send the driver to new RideScreen  /trip screen trip started now
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewTripScreen(userRideRequestDetails: widget.userRideRequestDetails),
          ),
        );
      } else {
        showCustomMsg(context, "User Delete This Request");
      }
    });
  }
}
