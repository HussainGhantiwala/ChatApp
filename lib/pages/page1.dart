// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_clone/chat/chat.dart';
import 'package:uber_clone/model/database.dart';

import '../main.dart';
import '../utilities/utils.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  String myUsername = "";
  Stream? userStream;
  Stream<QuerySnapshot>? chatRoomStream;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void getChatRooms() async {
    chatRoomStream = await DatabaseMethod().getChatRooms(myUsername);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
    getChatRooms();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('user').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  void getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    var document = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    setState(() {
      myUsername = document.data()!["username"];
    });
  }

  Widget chatList() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatRoomStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data!.docs[index];
                    return ChatRoomListTile(
                        ds['lastMessage'], ds.id, myUsername);
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Yoooooo!",
            style: TextStyle(fontSize: 25),
          ),
        ),
        body:
            // ignore: sized_box_for_whitespace

            Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: size.height / 14,
                  width: size.width / 1.2,
                  child: TextField(
                    controller: _search,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: "Search for Friends",
                        labelText: "Search",
                        suffixIcon: InkWell(
                          onTap: () {
                            search();
                          },
                          child: Icon(Icons.search_outlined),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              userMap != null
                  ? Stack(children: [
                      ListTile(
                        onTap: () {
                          var chatRoomId = getChatRoomIdByUsername(
                              myUsername, userMap!['username']);
                          Map<String, dynamic> chatRoomInfoMap = {
                            "users": [myUsername, userMap!['username']]
                          };

                          DatabaseMethod()
                              .createChatRoom(chatRoomId, chatRoomInfoMap);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatRoom(
                                      chatRoomId: chatRoomId,
                                      userMap: userMap!)));
                        },
                        leading: Container(
                            child: ClipOval(
                          child: Image(
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            image: userMap!['image'] == ''
                                ? NetworkImage(
                                    "https://www.tvinsider.com/wp-content/uploads/2019/08/the-boys-homelander-1014x570.jpg")
                                : NetworkImage(userMap!['image']),
                          ),
                        )),
                        title: Text(userMap!['username']),
                        subtitle: Text(
                          userMap!['email'],
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20, right: 15),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Text("Message"),
                          )
                        ],
                      ),
                    ])
                  : chatList(),
            ],
          ),
        ),
      ),
    );
  }

  Future search() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
                child: CircularProgressIndicator.adaptive(),
              ));
      await FirebaseFirestore.instance
          .collection('user')
          .where("username", isEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
        });
      });
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      Utils.showSnackBar("User not found");
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    // ignore: use_build_context_synchronousl
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String image = '';
  String name = '';
  String username = '';

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, '').replaceAll('_', "");
    QuerySnapshot querySnapshot = await DatabaseMethod().getUserInfo(username);
    print('something${querySnapshot.docs[0].id}');
    name = "${querySnapshot.docs[0]['username']}";
    image = querySnapshot.docs[0]['image'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image(
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              image: image == ''
                  ? NetworkImage(
                      'https://www.tvinsider.com/wp-content/uploads/2019/08/the-boys-homelander-1014x570.jpg')
                  : NetworkImage(image)),
        ),
        Column(
          children: [
            Text(name),
            Text(
              widget.lastMessage,
              style: TextStyle(color: Colors.white),
            )
          ],
        )
      ],
    );
  }

  @override
  void initState() {
    getThisUserInfo();

    super.initState();
  }
}
