import 'package:flutter/cupertino.dart';

import '../models/directions.dart';
import '../models/history_model.dart';

class AppInfo extends ChangeNotifier {
  DirectionModel? userPickUpLocation;
  DirectionModel? dropOffLocation;
  int countTotalTrips = 0;

  String _driverTotalEarnings = "0";
  String get driverTotalEarnings => _driverTotalEarnings;
  String driverAverageRating = "0";
  List<String> historyTripKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];
  void updatePickUpLocationAddress(DirectionModel userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(DirectionModel userDropOffLocation) {
    dropOffLocation = userDropOffLocation;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripKeys(List<String> tripKeysList) {
    historyTripKeysList = tripKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel historyModel) {
    allTripsHistoryInformationList.add(historyModel);
    notifyListeners();
  }

  updateDriverTotalEarnings(String driverEarnings) {
    _driverTotalEarnings = driverEarnings;
    notifyListeners();
  }

  updateDriverAverageRatings(String driverRatings) {
    driverAverageRating = driverRatings;
    notifyListeners();
  }
}
