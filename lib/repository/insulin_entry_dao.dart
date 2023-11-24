// ignore_for_file: constant_identifier_names

import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/repository/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class InsulinEntryDao extends GenericDAO {
  static const INSULIN_TABLE = 'InsulinEntry';

  Future<List<InsulinEntryModel>> getAllEntries() async {
    final database = await getDatabase();
    final List<Map<String, dynamic>> maps = await database.query(INSULIN_TABLE);
    return maps.map((e) => InsulinEntryModel.fromMap(e)).toList();
  }

  // Insert entry
  Future<int> insertEntry(final InsulinEntryModel entry) async {
    final Database db = await getDatabase();
    return await db.insert(
        INSULIN_TABLE,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
  }

  // Delete entry
  Future<void> deleteEntry(final int id) async {
    final Database db = await getDatabase();
    await db.delete(
      INSULIN_TABLE,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<InsulinEntryModel?>> retriveListForInterval(DateTime start, DateTime end) async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      INSULIN_TABLE,
      where: "timestamp BETWEEN ? AND ?",
      whereArgs: [start.toString(), end.toString()],
    );
    return maps.map((e) => InsulinEntryModel.fromMap(e)).toList();
  }
}