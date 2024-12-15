import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notes/services/crud/constants.dart';
import 'package:notes/services/crud/crud_exception.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  // Singleton construction
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException catch (_) {
      //empty
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount >= 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final id = await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(id: id, email: email);
  }

  Future<DatabaseUser> getOrCreateUser({
    required String email,
  }) {
    try {
      return getUser(email: email);
    } on UserNotFoundException catch (_) {
      return createUser(email: email);
    } catch (_) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserNotFoundException();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount >= 1) {
      throw NoteNotFoundException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deletedCount;
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserNotFoundException();
    }

    const text = '';
    final id = await db.insert(noteTable, {
      userIdColumn: dbUser.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: id,
      userId: dbUser.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateCount == 0) {
      throw NoteNotFoundException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      throw NoteNotFoundException();
    } else {
      final note = DatabaseNote.fromRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.toString(), dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException catch (_) {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      await db.close();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = [emailColumn] as String;

  @override
  String toString() => 'Person, ID=$id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = [userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID=$id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
