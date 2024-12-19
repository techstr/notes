import 'package:flutter/foundation.dart';

@immutable
class CloudStorageException implements Exception {
  const CloudStorageException();
}

class NoteNotCreatedException extends CloudStorageException {}

class NoteNotRetrievedException extends CloudStorageException {}

class NoteNotUpdateException extends CloudStorageException {}

class NoteNotDeleteExeception extends CloudStorageException {}
