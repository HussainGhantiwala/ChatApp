// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_clone/main.dart';
import 'package:uber_clone/pages/imageChange.dart';
import 'package:uber_clone/utilities/routes.dart';
import 'package:uber_clone/utilities/utils.dart';
import 'package:uuid/uuid.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _PageState();
}

class _PageState extends State<RegistrationPage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController lastnameTextEditingController = TextEditingController();
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  bool isObscure = true;
  bool changeButton =
      false; //we put a value Changebutton but for now its false nut later we will chnage it to true

  final _formKey = GlobalKey<FormState>();
  moveToHome(BuildContext context) async {
    //using async so that we can use await.
    //when you click the login button you will be directed to home page
    if (_formKey.currentState!.validate()) {
      setState(() {
        changeButton = true;
      });
      await Future.delayed(Duration(seconds: 1));
      // ignore: use_build_context_synchronously
      await Navigator.pushNamed(
          context,
          MyRoutes
              .loginRoute); //await is a function when you want your particular part of code to work at a particular duration
      setState(() {
        changeButton = false;
      });
    }
  }

  String imageUrl = "";
  void pickUploadImage() async {
    String fileName = Uuid().v1();
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);

    Reference ref =
        FirebaseStorage.instance.ref().child("images").child(fileName);
    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        //if the widget is big it will help to scroll
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(
                  "Create Account", //Whwn the user enters his/her name on the  username title his/her name will be written beside 'Welcome' thts why the stringe is empty above and to declare something we use '$'
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: "UberMoveBold"),
                ),
              ),
              SizedBox(
                height:
                    35.0, //space between the text like writing WELCOME 20px dowm(height) from the pic
              ),
              Padding(
                //it adds padding or empty space around a widget or a bunch of widgets. We can apply padding around any widget by placing it as the child of the Padding widget.
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 35.0),
                child: Column(
                  children: [
                    Stack(children: [
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
                    ]),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: nameTextEditingController,
                      //nothing but decorating your app or adding text as you can see below
                      decoration: InputDecoration(
                          hintText: "Enter First name",
                          labelText: "First name"),
                      validator: (value) {
                        //The validator method returns a string containing the error message when the user input is invalid or null if the user input is valid
                        if (value!.isEmpty) {
                          //when the value is empty it will return "Please enter user name"
                          return "Please enter your First name";
                        } else if (value.length < 3) {
                          //we use lenght here to see if the user has atleast entered 6 characters.
                          return "Full name must contain atleast 5 characters";
                        }
                        return null; //if he did then it will return null meaning no error.
                      },
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: lastnameTextEditingController,
                      //nothing but decorating your app or adding text as you can see below
                      decoration: InputDecoration(
                          hintText: "Enter Last name", labelText: "Last name"),
                      validator: (value) {
                        //The validator method returns a string containing the error message when the user input is invalid or null if the user input is valid
                        if (value!.isEmpty) {
                          //when the value is empty it will return "Please enter user name"
                          return "Please enter your Last name";
                        } else if (value.length < 3) {
                          //we use lenght here to see if the user has atleast entered 6 characters.
                          return "Last name must contain atleast 5 characters";
                        }
                        return null; //if he did then it will return null meaning no error.
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: usernameTextEditingController,
                      //nothing but decorating your app or adding text as you can see below
                      decoration: InputDecoration(
                          hintText: "Enter your prefered username",
                          labelText: "Username"),
                      validator: (value) {
                        //The validator method returns a string containing the error message when the user input is invalid or null if the user input is valid
                        if (value!.isEmpty) {
                          //when the value is empty it will return "Please enter user name"
                          return "Please enter your Username";
                        } else if (value.length < 6) {
                          //we use lenght here to see if the user has atleast entered 6 characters.
                          return "Username must contain atleast 5 characters";
                        }
                        return null; //if he did then it will return null meaning no error.
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: "Enter email address",
                          labelText: "Email address"),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) => email != null &&
                              !EmailValidator.validate(email)
                          ? 'Enter a valid email'
                          : null, //The validator method returns a string containing the error message when the user input is invalid or null if the user input is valid
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          hintText: "Please enter Phone number",
                          labelText: "Phone No"),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "Enter the Phone number";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: passwordTextEditingController,
                      obscureText: isObscure, //nothing but hiding your password
                      decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                              icon: Icon(isObscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded))),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.length < 6
                          ? 'Enter Minimum 6 Characters'
                          : null,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      maxLines: 5,
                      controller: bioTextEditingController,
                      //nothing but decorating your app or adding text as you can see below
                      decoration: InputDecoration(
                          hintText: "Write about yourself", labelText: "Bio"),
                      validator: (value) {
                        //The validator method returns a string containing the error message when the user input is invalid or null if the user input is valid
                        if (value!.isEmpty) {
                          //when the value is empty it will return "Please enter user name"
                          return "Please write something";
                        } else if (value.length < 10) {
                          //we use lenght here to see if the user has atleast entered 6 characters.
                          return "C'mon seriously..? Write more";
                        }
                        return null; //if he did then it will return null meaning no error.
                      },
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    InkWell(
                      //inkwell id best or more likr good for animation
                      onTap: () =>
                          registerNewUser(), //if tap the log in  button it will move to home screen.
                      child: AnimatedContainer(
                        duration: Duration(
                            seconds:
                                1), //animated container requires Duration its like  must , it returns the animation at the exact duration written here.
                        width: changeButton
                            ? 50
                            : 150, //we are designing a button here by giving width,
                        //but were kept "ChangeButton?50:150" because if the change button value is true the width will be 50 if false 150. and '?' means true ':' false when a boolian is giving
                        height: 50,
                        alignment: Alignment.center,
                        // ignore: sort_child_properties_last
                        child: changeButton
                            ? Icon(Icons.done,
                                color: Colors
                                    .white) //the icon will turn into tick mark when the Login button is clicked.
                            : Text(
                                "Sign In", //from here we are designing the button like adding text colour of the text and all
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
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
                          borderRadius: BorderRadius.circular(changeButton
                              ? 50
                              : 8), //same like width if the ChangeButton is true the corner will be 50 if flase then 8
                        ),
                      ),
                    ),
                    //)
                    SizedBox(height: 25),
                    FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, MyRoutes.loginRoute);
                        },
                        child: Text('Already have a account? Log in')),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Future registerNewUser() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularProgressIndicator.adaptive(),
              ));
      User? user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim()))
          .user;
      if (user != null) {
        user.updateProfile(displayName: usernameTextEditingController.text);
        await _firestore
            .collection('user')
            .doc(_firebaseAuth.currentUser?.uid)
            .set({
          "first name": nameTextEditingController.text,
          "last name": lastnameTextEditingController.text,
          "username": usernameTextEditingController.text,
          "email": emailTextEditingController.text,
          "bio": bioTextEditingController.text,
          "image": imageUrl,
          "status": 'Unavailable',
          "uid": _firebaseAuth.currentUser!.uid
        });
      }
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.pushNamed(MyRoutes.loginRoute);
  }
}
