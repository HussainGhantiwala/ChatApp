// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/utilities/utils.dart';

import '../utilities/routes.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  bool changeButton = false;
  TextEditingController emailTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, MyRoutes.loginRoute),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(children: [
          Container(
            height: 300,
            width: 300,
            child: Image.asset("assets/images/Password.jpg"),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter your registered email to reset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        hintText: "Enter email address",
                        labelText: "Email address"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        email != null && !EmailValidator.validate(email)
                            ? 'Enter a valid email'
                            : null,
                  ),
                  SizedBox(height: 50),
                  InkWell(
                    //inkwell id best or more likr good for animation
                    onTap: () =>
                        resetPassword(), //if tap the log in  button it will move to home screen.
                    child: AnimatedContainer(
                      duration: Duration(
                          seconds:
                              1), //animated container requires Duration its like  must , it returns the animation at the exact duration written here.
                      width: changeButton
                          ? 50
                          : 200, //we are designing a button here by giving width,
                      //but were kept "ChangeButton?50:150" because if the change button value is true the width will be 50 if false 150. and '?' means true ':' false when a boolian is giving
                      height: 50,
                      alignment: Alignment.center,
                      // ignore: sort_child_properties_last
                      child: changeButton
                          ? Icon(Icons.done,
                              color: Colors
                                  .white) //the icon will turn into tick mark when the Login button is clicked.
                          : Text(
                              "Reset Password", //from here we are designing the button like adding text colour of the text and all
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                      decoration: BoxDecoration(
                        //from here we are adding decoration to box like the colour of the box and all
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(changeButton
                            ? 50
                            : 8), //same like width if the ChangeButton is true the corner will be 50 if flase then 8
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailTextEditingController.text.trim());
      Utils.showSnackBar('Reset link sent');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
