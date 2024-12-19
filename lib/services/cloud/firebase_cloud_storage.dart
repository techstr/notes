import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_constants.dart';
import 'package:notes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // Singleton constructor
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<Note>> allNotes({required String userId}) =>
      notes.snapshots().map(
            (event) => event.docs
                .map(
                  (doc) => Note.fromSnapshot(doc),
                )
                .where((note) => note.userId == userId),
          );

  Future<Note> createNote({
    required String userId,
  }) async {
    try {
      final doc = await notes.add({
        userIdFieldName: userId,
        textFieldName: '',
      });
      final fetchedNote = await doc.get();
      return Note(id: fetchedNote.id, userId: userId, text: '');
    } catch (_) {
      throw NoteNotCreatedException();
    }
  }

  Future<Iterable<Note>> getNotes({required String userId}) async {
    try {
      return await notes
          .where(
            userIdFieldName,
            isEqualTo: userId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => Note.fromSnapshot(doc),
            ),
          );
    } catch (_) {
      throw NoteNotRetrievedException();
    }
  }

  Future<void> updateNote({
    required String id,
    required String text,
  }) async {
    try {
      await notes.doc(id).update({
        textFieldName: text,
      });
    } catch (_) {
      throw NoteNotUpdateException();
    }
  }

  Future<void> deleteNote({
    required String id,
  }) async {
    try {
      await notes.doc(id).delete();
    } catch (_) {
      throw NoteNotDeleteExeception();
    }
  }
}
