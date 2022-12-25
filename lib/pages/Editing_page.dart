// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_clone/Widget/app_bar_widget.dart';
import 'package:uber_clone/Widget/button_widget.dart';
import 'package:uber_clone/utilities/routes.dart';
import 'package:uber_clone/utilities/user_pefrences.dart';
import 'package:uber_clone/utilities/utils.dart';
import 'package:uuid/uuid.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  String imageUrl = '';
  final _displayNameController = TextEditingController();
  final _displayBioController = TextEditingController();
  final users = FirebaseAuth.instance.currentUser;

  void pickUploadImage() async {
    String fileName = Uuid().v1();
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);

    Reference ref =
        FirebaseStorage.instance.ref().child("image").child("$fileName.jpg");
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  void getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    var document = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    setState(() {
      _displayNameController.text = document.data()!["username"];
      _displayBioController.text = document.data()!['bio'];
      imageUrl = document.data()!['image'];
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios))),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32),
        physics: BouncingScrollPhysics(),
        children: [
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: Ink.image(
                      image: imageUrl == ''
                          ? NetworkImage(
                              "https://www.tvinsider.com/wp-content/uploads/2019/08/the-boys-homelander-1014x570.jpg")
                          : NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      width: 128,
                      height: 128,
                      child: InkWell(
                        onTap: pickUploadImage,
                      ),
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
            height: 40,
          ),
          TextField(
            controller: _displayNameController,
            decoration: InputDecoration(
              hintText: _displayNameController.text,
              labelText: "Change username",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          TextField(
            controller: _displayBioController,
            decoration: InputDecoration(
              hintText: _displayBioController.text,
              labelText: "Change your bio",
              hintMaxLines: 5,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 5,
          ),
          SizedBox(
            height: 50,
          ),
          ButtonWidget(
              text: "Save",
              onClicked: () async {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ));
                final users = FirebaseAuth.instance.currentUser;
                final String name = _displayNameController.text;
                final String bio = _displayBioController.text;
                final image = imageUrl;
                if (users != null) {
                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(users.uid)
                      .update({'username': name, "bio": bio, 'image': image});
                  Utils.showSnackBar('Profile updated successfully');
                }

                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, MyRoutes.profileRoute);
              })
        ],
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            Icons.add_a_photo_outlined,
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
