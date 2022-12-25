// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetUserName extends StatelessWidget {
  final String documentId;
  GetUserName({required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference user = FirebaseFirestore.instance.collection('user');
    return FutureBuilder<DocumentSnapshot>(
        future: user.doc(documentId).get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text(
                // ignore: prefer_adjacent_string_concatenation
                'First Name: ${data['first name']}' +
                    ' ' +
                    '${data['last name']}');
          }
          // ignore: prefer_const_constructors
          return Text('loading...');
        }));
  }
}
