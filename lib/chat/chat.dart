// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:uber_clone/model/database.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  const ChatRoom({Key? key, required this.chatRoomId, required this.userMap})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Map<String, dynamic>? userMap;
  String username = "";
  late Stream<QuerySnapshot> messageStream;
  String bio = "";
  String chatRoomId = "";

  File? imageFile;
  void getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    var document = await FirebaseFirestore.instance
        .collection('user')
        .doc(user!.uid)
        .get();
    setState(() {
      username = document.data()!["username"];
      bio = document.data()!['bio'];
    });
    chatRoomId = getChatRoomIdByUsername(widget.chatRoomId, username);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  getAndSetMessage() async {
    messageStream = await DatabaseMethod().getChatRoomMessages(chatRoomId);
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Widget chatMessages() {
    return StreamBuilder<QuerySnapshot>(
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return Text(ds["message"]);
              });
        },
        stream: messageStream);
  }

  String messageId = "";

  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? image;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  /* void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "time": FieldValue.serverTimestamp()
      };
      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Text");
    }

    
  */
  void onSendMessage(bool sendClicked) async {
    if (_message.text.isNotEmpty) {
      var lastMessageTimeStamp = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "time": lastMessageTimeStamp,
        "type": 'text'
      };
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethod()
          .addMessage(widget.chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": _message.text,
          "lastMessageTimeStamp": lastMessageTimeStamp,
          "lastMessageSendBy": _auth.currentUser!.email
        };
        DatabaseMethod()
            .updateLastMessageSend(widget.chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          _message.text = "";
          messageId = "";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('user')
            .doc(widget.userMap['uid'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Row(
                children: [
                  Stack(children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: Image(
                          image: snapshot.data!['image'] == ''
                              ? NetworkImage(
                                  "https://www.tvinsider.com/wp-content/uploads/2019/08/the-boys-homelander-1014x570.jpg")
                              : NetworkImage(snapshot.data!['image']),
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 3,
                      child: CircleAvatar(
                        radius: 4.2,
                        backgroundColor: snapshot.data!['status'] == 'Offline'
                            ? Colors.red
                            : Colors.green,
                      ),
                    )
                  ]),
                  Container(
                    margin: EdgeInsets.only(left: 18),
                    child: Text(
                      widget.userMap['username'],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      )
          /*widget.userMap['username'],
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),*/
          ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: Size.height / 1.3,
                width: Size.width,
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chatroom')
                        .doc(widget.chatRoomId)
                        .collection('chats')
                        .orderBy("time", descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                            padding: EdgeInsets.only(bottom: 10, top: 16),
                            itemCount: snapshot.data!.docs.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> map =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              return messages(Size, map, context);
                            });
                      } else {
                        return Container();
                      }
                    })),
            Container(
              height: Size.height / 12,
              width: Size.width,
              alignment: Alignment.bottomCenter,
              child: Container(
                height: Size.height / 12,
                width: Size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      height: Size.height / 14,
                      width: Size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () => getImage(),
                              icon: Icon(Icons.photo)),
                          hintText: "Message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: IconButton(
                          onPressed: () {
                            onSendMessage(true);
                          },
                          icon: Icon(Icons.send_rounded)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == 'text'
        ? Row(
            mainAxisAlignment: map['sendby'] == _auth.currentUser!.displayName
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                width: size.width,
                alignment: map['sendby'] == _auth.currentUser!.displayName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    color: map['sendby'] == _auth.currentUser!.displayName
                        ? Colors.deepPurple
                        : Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomRight:
                          map['sendby'] == _auth.currentUser!.displayName
                              ? Radius.circular(0)
                              : Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft:
                          map['sendby'] == _auth.currentUser!.displayName
                              ? Radius.circular(24)
                              : Radius.circular(0),
                    ),
                  ),
                  child: Text(
                    map['message'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          )
        : map['type'] == 'img'
            ? Container(
                height: size.height / 2.5,
                width: size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                alignment: map['sendby'] == _auth.currentUser!.displayName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShowImage(
                        imageUrl: map['message'],
                      ),
                    ),
                  ),
                  child: Container(
                    height: size.height / 2.5,
                    width: size.width / 2,
                    decoration: BoxDecoration(border: Border.all()),
                    alignment: map['message'] != "" ? null : Alignment.center,
                    child: map['message'] != ""
                        ? Image.network(
                            map['message'],
                            fit: BoxFit.cover,
                          )
                        : CircularProgressIndicator(),
                  ),
                ),
              )
            : Container();
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
