// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:uber_clone/Widget/drawer.dart';
import 'package:uber_clone/pages/page1.dart';
import 'package:uber_clone/pages/profile.dart';
import 'package:uber_clone/pages/profile2.dart';

class MainNav extends StatefulWidget {
  const MainNav({Key? key}) : super(key: key);

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  List pages = [MainScreen(), Profile()];
  var _currentIndex = 0;
  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: (SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: onTap,
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.teal,
          ),
        ],
      )),
    );
  }
}
