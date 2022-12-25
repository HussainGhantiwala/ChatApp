import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uber_clone/chat/chat_contact.dart';
import 'package:uber_clone/chat/message.dart';
import 'package:uber_clone/model/user_model.dart';
import 'package:uber_clone/utilities/message_enum.dart';
import 'package:uber_clone/utilities/utils.dart';
import 'package:uuid/uuid.dart';

final ChatRepositoryProvider = Provider(((ref) => ChatRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance)));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({required this.firestore, required this.auth});
  void _saveDataToCollection(
    UserModel senderUserData,
    UserModel recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text);
    await firestore
        .collection('user')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(recieverChatContact.toMap());

    var senderChatContact = ChatContact(
        name: recieverUserData.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text);
    await firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(senderChatContact.toMap());
  }

  void _saveMessageToMessageSubcollection(
      {required String recieverUserId,
      required String text,
      required DateTime timeSent,
      required String messageId,
      required String username,
      required recieverUsername,
      required MessageEnum messageType}) async {
    final message = Message(
        senderId: auth.currentUser!.uid,
        recieverId: recieverUserId,
        text: text,
        type: messageType,
        timeSent: timeSent,
        messageId: messageId,
        isSeen: false);
    await firestore
        .collection('user')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore
        .collection('user')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel recieverUserData;
      var userDataMap =
          await firestore.collection('user').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);
      var messageId = const Uuid().v1();

      _saveDataToCollection(
          senderUser, recieverUserData, text, timeSent, recieverUserId);
      _saveMessageToMessageSubcollection(
          recieverUserId: recieverUserId,
          text: text,
          timeSent: timeSent,
          messageType: MessageEnum.text,
          messageId: messageId,
          recieverUsername: recieverUserData.name,
          username: senderUser.name);
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }
}
