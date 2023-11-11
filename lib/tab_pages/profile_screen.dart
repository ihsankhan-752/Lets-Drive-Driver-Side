import 'package:flutter/material.dart';

import '../global/globals.dart';
import '../splash_screen/splash_screen.dart';
import '../widgets/info_design_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //name
            Text(
              onlineDriverData.name ?? "",
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              titleStarRating + " Driver",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
                thickness: 2,
                height: 2,
              ),
            ),

            SizedBox(height: 40),
            //phone information
            InfoDesignUi(
              textInfo: onlineDriverData.phone ?? "",
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUi(
              textInfo: onlineDriverData.email ?? "",
              iconData: Icons.email,
            ),
            InfoDesignUi(
              textInfo:
                  onlineDriverData.car_color! + " " + onlineDriverData.car_model! + " " + onlineDriverData.car_number!,
              iconData: Icons.car_repair,
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                fAuth.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (_) => MySplashScreen()));
              },
              child: Text("LogOut"),
            ),
          ],
        ),
      ),
    );
  }
}
