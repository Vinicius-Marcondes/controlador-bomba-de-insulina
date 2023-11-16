// ignore_for_file: constant_identifier_names

import 'package:controlador_bomba_de_insulina/model/system_model.dart';
import 'package:controlador_bomba_de_insulina/repository/generic_dao.dart';

class SystemDao extends GenericDAO {
  static const SYSTEM_TABLE = 'System';

  SystemDao() : super();

  // Set system initialized
  Future<int> setSystemInitialized() async {
    final db = await getDatabase();
    return await db.update(
      SYSTEM_TABLE,
      SystemModel(id: 1, initialized: 1).toMap(),
      where: "id = ?",
      whereArgs: [0],
    );
  }

  // Get initialized state of the system
  Future<bool> isSystemInitialized() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        SYSTEM_TABLE
    );

    SystemModel systemModel = SystemModel.fromMap(maps.first);
    return systemModel.initialized == 1;
  }

  // Get all records from System
  Future<List<SystemModel>> getAll() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(SYSTEM_TABLE);

    return List.generate(maps.length, (i) {
      return SystemModel.fromMap(maps[i]);
    });
  }
}
