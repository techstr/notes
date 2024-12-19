import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:notes/services/cloud/cloud_storage_constants.dart';

@immutable
class Note {
  final String id;
  final String userId;
  final String text;

  const Note({
    required this.id,
    required this.userId,
    required this.text,
  });

  Note.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()[userIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
