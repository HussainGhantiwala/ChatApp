// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/Widget/Profile_Widget.dart';
import 'package:uber_clone/Widget/app_bar_widget.dart';
import 'package:uber_clone/Widget/button_widget.dart';
import 'package:uber_clone/pages/Editing_page.dart';
import 'package:uber_clone/utilities/routes.dart';
import 'package:uber_clone/utilities/user_pefrences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final users = FirebaseAuth.instance.currentUser;
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String name = 'loading...';
  String bio = 'loading...';
  String image =
      "https://www.tvinsider.com/wp-content/uploads/2019/08/the-boys-homelander-1014x570.jpg";
  void getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    var document = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    setState(() {
      name = document.data()!["username"];
      bio = document.data()!['bio'];
      image = document.data()!['image'];
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, MyRoutes.navRoute);
                },
                icon: Icon(Icons.arrow_back_ios))),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: Ink.image(
                        image: image == ''
                            ? NetworkImage(
                                "https://www.tvinsider.com/wp-content/uploads/2019/08/the-boys-homelander-1014x570.jpg")
                            : NetworkImage(image),
                        fit: BoxFit.cover,
                        width: 128,
                        height: 128,
                        child: InkWell(onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) => EditPage())));
                        }),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 4,
                      child: buildEditIcon(Colors.deepPurple)),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  users!.email!,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 24,
                ),
                buildSignOutButton(),
                SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      Text(
                        "About",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        bio,
                        style: TextStyle(fontSize: 16, height: 1.4),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildSignOutButton() => ButtonWidget(
      text: "SignOut",
      onClicked: () {
        FirebaseAuth.instance.signOut();
      });

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          // ignore: prefer_const_constructors
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
