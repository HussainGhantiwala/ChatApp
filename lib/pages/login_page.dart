// ignore_for_file: prefer_const_constructors, deprecated_member_use
import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/main.dart';
import 'package:uber_clone/utilities/routes.dart';
import 'package:uber_clone/utilities/utils.dart';

import '../utilities/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = "";
  // ignore: unused_element

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool isObscure = true;
  bool changeButton =
      false; //we put a value Changebutton but for now its false nut later we will chnage it to true
  final _formKey = GlobalKey<FormState>();

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
              // ignore: avoid_unnecessary_containers
              Container(
                height: 250,
                width: 350,
                margin: const EdgeInsets.only(top: 50),
                child: Image.asset("assets/images/Login.png"),
              ),
              SizedBox(
                height: 10,
              ), //adding image ton your app so for now i am adding this to my login page
              Text(
                "Welcome $name", //Whwn the user enters his/her name on the  username title his/her name will be written beside 'Welcome' thts why the stringe is empty above and to declare something we use '$'
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: "UberMoveBold"),
              ),
              SizedBox(
                height:
                    25.0, //space between the text like writing WELCOME 20px dowm(height) from the pic
              ),
              Padding(
                //it adds padding or empty space around a widget or a bunch of widgets. We can apply padding around any widget by placing it as the child of the Padding widget.
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 35.0),
                child: Column(
                  children: [
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
                    SizedBox(
                      height: 10.0, //
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
                      height: 40.0,
                    ),
                    InkWell(
                      //inkwell id best or more likr good for animation
                      onTap: () =>
                          signIn(), //if tap the log in  button it will move to home screen.
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
                                "Login", //from here we are designing the button like adding text colour of the text and all
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
                    //ElevatedButton(
                    //adding button to your app
                    //child: Text(
                    //"Login",
                    //textAlign: TextAlign.center,
                    //),
                    //style: TextButton.styleFrom(minimumSize: Size(80, 43)),
                    //onPressed: () {
                    //Navigator.pushNamed(context, MyRoutes.homeRoute);
                    //},
                    //)
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: 10),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, MyRoutes.forgotRoute);
                      },
                    ),
                    SizedBox(height: 25),
                    FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, MyRoutes.registrationRoute);
                        },
                        child: Text('Don\'t have an account, sign up here')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularProgressIndicator.adaptive(),
              ));
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim());
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      Utils.showSnackBar(e.message);
    }
    // ignore: use_build_context_synchronously
    navigatorKey.currentState!.pushNamed(MyRoutes
        .mainRoute); //when the user enters the valid email and pass or the email he or she registered will be redirected to the next page or the contiued page
  }
}
