// ignore_for_file: constant_identifier_names

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class GenericDAO {

  static const _databaseName = "freeFlow.db";
  static const _databaseVersion = 1;

  static const SYSTEM_TABLE = 'System';
  static const USER_TABLE = 'User';
  static const INSULIN_ENTRY_TABLE = 'InsulinEntry';


  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: _onCreate,
      version: _databaseVersion,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $SYSTEM_TABLE(id INTEGER PRIMARY KEY, initialized INTEGER NOT NULL, pumpRemoteId TEXT, insulinStock INT NOT NULL, pumpLocked INT NOT NULL);');
    await db.execute('CREATE TABLE $USER_TABLE(id INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT, birthDate TEXT, image BLOB, height REAL, weight REAL, diabetesType INTEGER, basalInsulin REAL, insulinRate TEXT);');
    await db.execute('CREATE TABLE $INSULIN_ENTRY_TABLE(id INTEGER PRIMARY KEY, units INTEGER, glicemia INT, timestamp TEXT, userId INTEGER, FOREIGN KEY(userId) REFERENCES User(id));');

    await db.insert(SYSTEM_TABLE, {"id": 0, "initialized": 0, "pumpRemoteId": null, "insulinStock": 0, "pumpLocked": 0});
  }
}
