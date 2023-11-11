import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../global/globals.dart';
import '../info_handler/app_info.dart';

class RatingScreen extends StatefulWidget {
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double ratings = 0;
  @override
  void initState() {
    getRatingNumbers();

    super.initState();
  }

  getRatingNumbers() {
    setState(() {
      ratings = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRating);
    });
    setupRatingTitle();
  }

  setupRatingTitle() {
    if (ratings == 1) {
      setState(() {
        titleStarRating = "Very Bad";
      });
    }
    if (ratings == 2) {
      setState(() {
        titleStarRating = "Bad";
      });
    }
    if (ratings == 3) {
      setState(() {
        titleStarRating = "Good";
      });
    }
    if (ratings == 4) {
      setState(() {
        titleStarRating = "Very Good";
      });
    }
    if (ratings == 5) {
      setState(() {
        titleStarRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22),
              Text(
                "Your Ratings",
                style: TextStyle(
                  color: Colors.black54,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 22),
              Divider(thickness: 4, height: 4),
              SizedBox(height: 22),
              SmoothStarRating(
                color: Colors.green,
                borderColor: Colors.green,
                size: 35,
                rating: ratings,
                allowHalfRating: false,
                starCount: 5,
              ),
              SizedBox(height: 12),
              Text(
                titleStarRating,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
