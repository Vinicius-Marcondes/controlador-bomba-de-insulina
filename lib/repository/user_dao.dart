// ignore_for_file: constant_identifier_names

import 'package:controlador_bomba_de_insulina/repository/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../model/user_model.dart';

class UserDao extends GenericDAO {
  static const USER_TABLE = 'User';

  Future<int> insertUser(UserModel user) async {
    final Database db = await getDatabase();

    try {
      return await db.insert(
        USER_TABLE,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 0;
    }
  }

  Future<UserModel> getUser() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(USER_TABLE);
    return UserModel.fromMap(maps.first);
  }

  Future<void> updateUser(final UserModel user) async {
    final Database db = await getDatabase();

    await db.update(
      USER_TABLE,
      user.toMap(),
      where: "id = ?",
      whereArgs: [user.id],
    );
  }
}
