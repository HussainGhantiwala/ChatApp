import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_clone/utilities/user.dart';

class UserPrefrences {
  static const myUser = Users(
    imagePath:
        "https://www.tvinsider.com/wp-content/uploads/2019/08/the-boys-homelander-1014x570.jpg",
    email: "hussainghantiwala8@gmail.com",
    bio: "Once a short guy said ..Give up on your dreams and die.",
    isDarkMode: true,
    isOnline: false,
  );
}
