// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageChange extends StatefulWidget {
  const ImageChange({Key? key}) : super(key: key);

  @override
  State<ImageChange> createState() => _ImageChangeState();
}

class _ImageChangeState extends State<ImageChange> {
  String imageUrl = "";
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

  @override
  Widget build(BuildContext context) {
    return Center(
      // ignore: prefer_const_literals_to_create_immutables
      child: Stack(children: [
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
              child: InkWell(onTap: pickUploadImage),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: buildEditIcon(Colors.deepPurple),
        )
      ]),
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
