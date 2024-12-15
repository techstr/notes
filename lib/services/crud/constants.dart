const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloudColumn = "is_synced_with_cloud";
const dbName = "notes.db";
const noteTable = "note";
const userTable = "user";
const createUserTable = '''
  CREATE TABLE IF NOT EXISTS "user" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "email" TEXT NOT NULL
  )
''';

const createNotesTable = '''
  CREATE TABLE IF NOT EXISTS "note" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER NOT NULL,
    "text" TEXT,
    "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0
  )
''';
