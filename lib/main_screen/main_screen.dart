import 'package:flutter/material.dart';

import '../tab_pages/earning_screen.dart';
import '../tab_pages/home.dart';
import '../tab_pages/profile_screen.dart';
import '../tab_pages/rating_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectIndex = 0;

  onItemClicked(int index) {
    setState(() {
      selectIndex = index;
      controller!.index = selectIndex;
    });
  }

  @override
  void initState() {
    controller = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(),
          EarningScreen(),
          RatingScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: selectIndex,
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        onTap: onItemClicked,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Earning"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Rating"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}
