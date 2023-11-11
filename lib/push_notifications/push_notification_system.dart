import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/globals.dart';
import '../models/user_ride_request_information_model.dart';
import '../widgets/custom_msg.dart';
import 'notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //1.terminated state
    //when App is Completely Close
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      //remote message will bring all the information that we want

      if (remoteMessage != null) {
        readUserRideRequestInformation(context, remoteMessage.data['rideRequestId']);

        //display ride request information and user Information
      }
    });

    //2. Foreground
    //when App is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      //display ride request information and user Information
      readUserRideRequestInformation(context, remoteMessage!.data['rideRequestId']);
    });

    //3.background
    //when the app is in background and receive a push notification

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      //display ride request information and user Information
      readUserRideRequestInformation(context, remoteMessage!.data['rideRequestId']);
    });
  }

  readUserRideRequestInformation(BuildContext context, String userRideRequestId) {
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).once().then((snapData) {
      if (snapData.snapshot.value != null) {
        audioPlayer.open(Audio("music/music_notification.mp3"));
        audioPlayer.play();
        print("+++++++++++++Hello");

        double originLat = double.parse((snapData.snapshot.value as Map)['origin']['latitude']);

        print("++++++++++++++++++++++++++$originLat");
        double originLng = double.parse((snapData.snapshot.value as Map)['origin']['longitude']);
        String originAddress = (snapData.snapshot.value as Map)['originAddress'];

        double destinationLat = double.parse((snapData.snapshot.value as Map)['destination']['latitude']);

        double destinationLng = double.parse((snapData.snapshot.value as Map)['destination']['longitude']);

        String destinationAddress = (snapData.snapshot.value as Map)['destinationAddress'];

        // String username = (snapData.snapshot.value as Map)['username'];
        // String userPhone = (snapData.snapshot.value as Map)['userPhone'];

        String? rideRequestId = snapData.snapshot.key;
        print("Ride Request ID===========================>$rideRequestId");

        UserRideRequestInformationModel userRideRequestDetails = UserRideRequestInformationModel();

        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;
        //
        // userRideRequestDetails.username = username;
        // userRideRequestDetails.userPhone = userPhone;

        userRideRequestDetails.rideRequestId = rideRequestId;
        print("==============>>>>Notification Received");

        showDialog(
            context: context,
            builder: (_) {
              return NotificationDialogBox(userRideRequestDetails: userRideRequestDetails);
            });
      } else {
        showCustomMsg(context, "This Ride Request not exist");
      }
    });
  }

  Future getToken() async {
    String? token = await messaging.getToken();
    print("Fcm Registration Token:$token");
    //we will use cloud firestore for our app
    FirebaseDatabase.instance.ref().child("drivers").child(currentFirebaseUser!.uid).child("token").set(token);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
