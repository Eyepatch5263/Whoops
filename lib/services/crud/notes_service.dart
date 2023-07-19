import 'dart:js_interop';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crudexceptions.dart';



class NotesService {
  Database? _db;

  Future<DatabaseNotes> updateNotes(
      {required DatabaseNotes note, required String text}) async {
    final db = _getDatabaseOrThrow();
    final updatesCount = await db.update(
      notesTable,
      {textColumn: text, isSyncedWithCloud: 0},
    );
    if (updatesCount == 0) {
      throw CouldNotFindUser();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
    );
    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: "id=?",
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNotes.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(notesTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: "id=?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    //make sure owner exist in the database with correct id
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = "";
    final noteId = await db.insert(notesTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedWithCloud: 1});
    final note = DatabaseNotes(
        id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      notesTable,
      limit: 1,
      where: "email=?",
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = db.query(
      userTable,
      limit: 1,
      where: "email=?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isDefinedAndNotNull) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: "email=?",
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    } else {}
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create the user table
      await db.execute(createUserTable);

      //create the notes table
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;
  @override
  String toString() => "Person, ID=$id, email=$email";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map["is_synced_with_cloud"] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Notes, ID=$id, userId=$userId, isSyncedWithCloud=$isSyncedWithCloud, text=$text";

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const notesTable = "note";
const userTable = "user";
const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedWithCloud = "is_synced_With_cloud";

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user"(
	      "id"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNotesTable = '''CREATE TABLE IF NOT EXISTS "notes" (
	      "id"	INTEGER NOT NULL,
	      "user_id"	INTEGER NOT NULL,
	      "text"	TEXT,
	      "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	      FOREIGN KEY("user_id") REFERENCES "user"("id"),
	      PRIMARY KEY("id" AUTOINCREMENT)
        );''';
