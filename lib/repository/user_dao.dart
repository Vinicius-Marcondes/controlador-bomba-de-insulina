// ignore_for_file: constant_identifier_names

import 'package:controlador_bomba_de_insulina/repository/generic_dao.dart';
import 'package:sqflite/sqflite.dart';

import '../model/user_model.dart';

class UserDao extends GenericDAO {
  static const USER_TABLE = 'User';

  Future<void> insertUser(UserModel user) async {
    final Database db = await getDatabase();

    await db.insert(
      USER_TABLE,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel> getUser(int id) async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(USER_TABLE, where: "id = ?", whereArgs: [id]);

    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(USER_TABLE);

    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }

  Future<void> updateUser(UserModel user) async {
    final Database db = await getDatabase();

    await db.update(
      USER_TABLE,
      user.toMap(),
      where: "firstName = ?",
      whereArgs: [user.firstName],
    );
  }

  Future<void> deleteUser(int id) async {
    final Database db = await getDatabase();

    await db.delete(
      USER_TABLE,
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
