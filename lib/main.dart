// ignore_for_file: prefer_const_constructors
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uber_clone/Theme/theme.dart';
import 'package:uber_clone/chat/chat.dart';
import 'package:uber_clone/pages/Editing_page.dart';
import 'package:uber_clone/pages/forgot_password.dart';
import 'package:uber_clone/pages/login_page.dart';
import 'package:uber_clone/pages/main_page.dart';
import 'package:uber_clone/pages/page1.dart';
import 'package:uber_clone/pages/profile.dart';
import 'package:uber_clone/pages/profile2.dart';
import 'package:uber_clone/pages/registration_page.dart';
import 'package:uber_clone/utilities/NavBar.dart';
import 'package:uber_clone/utilities/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uber_clone/utilities/user_pefrences.dart';
import 'package:uber_clone/utilities/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: const MyApp()));
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = UserPrefrences.myUser;
    // ignore: duplicate_ignore
    return ThemeProvider(
      initTheme: user.isDarkMode ? MyTheme.darkTheme : MyTheme.lightTheme,
      child: MaterialApp(
        theme: user.isDarkMode ? MyTheme.darkTheme : MyTheme.lightTheme,
        scaffoldMessengerKey: Utils.messengerKey,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        initialRoute: MyRoutes.mainRoute,
        routes: {
          MyRoutes.loginRoute: (context) => LoginPage(),
          MyRoutes.registrationRoute: (context) => RegistrationPage(),
          MyRoutes.mainRoute: (context) => MainPage(),
          MyRoutes.screenRoute: (context) => MainScreen(),
          MyRoutes.forgotRoute: (context) => ForgotPassword(),
          MyRoutes.navRoute: (context) => MainNav(),
          MyRoutes.profileRoute: (context) => Profile(),
          MyRoutes.editRoute: (context) => EditPage(),
        },
      ),
    );
  }
}
