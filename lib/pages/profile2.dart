// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/read%20data/get_user_name.dart';

class ProfileTwo extends StatefulWidget {
  const ProfileTwo({Key? key}) : super(key: key);

  @override
  State<ProfileTwo> createState() => _ProfileTwoState();
}

class _ProfileTwoState extends State<ProfileTwo> {
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  final user = FirebaseAuth.instance.currentUser;
  //document IDs
  List<String> docIDs = [];

  //get doc IDs
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('user')
        .get()
        .then((value) => value.docs.forEach((document) {
              print(document.reference);
              docIDs.add(document.reference.id);
            }));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: getDocId(),
        builder: ((context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: size.height / 14,
                  width: 400,
                  child: ListView.builder(
                      itemCount: docIDs.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                          title: GetUserName(documentId: docIDs[index]),
                        );
                      })),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: size.height / 14,
                    width: 400,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      // ignore: prefer_interpolation_to_compose_strings
                      children: [Text("User's Email:" + ' ' + user!.email!)],
                    )),
                SizedBox(
                  height: 50,
                ),
                InkWell(
                  //inkwell id best or more likr good for animation
                  onTap: () => FirebaseAuth.instance.signOut(),
                  //if tap the log in  button it will move to home screen.
                  child: AnimatedContainer(
                    duration: Duration(
                        seconds:
                            1), //animated container requires Duration its like  must , it returns the animation at the exact duration written here.
                    width:
                        150, //we are designing a button here by giving width,
                    //but were kept "ChangeButton?50:150" because if the change button value is true the width will be 50 if false 150. and '?' means true ':' false when a boolian is giving
                    height: 50,
                    alignment: Alignment.center,
                    // ignore: sort_child_properties_last
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white),
                    ), //the icon will turn into tick mark when the Login button is clicked.
                    decoration: BoxDecoration(
                      //from here we are adding decoration to box like the colour of the box and all
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        // ignore: prefer_const_literals_to_create_immutables
                        colors: [
                          Color.fromARGB(255, 105, 38, 146),
                          Color.fromARGB(255, 45, 12, 80)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                          8), //same like width if the ChangeButton is true the corner will be 50 if flase then 8
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
