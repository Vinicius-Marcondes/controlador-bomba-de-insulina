// ignore_for_file: constant_identifier_names

import 'package:controlador_bomba_de_insulina/model/system_model.dart';
import 'package:controlador_bomba_de_insulina/repository/generic_dao.dart';

class SystemDao extends GenericDAO {
  static const SYSTEM_TABLE = 'System';

  SystemDao() : super();

  // Set system initialized
  Future<int> updateSystem(final SystemModel systemModel) async {
    final db = await getDatabase();
    return await db.update(
      SYSTEM_TABLE,
      systemModel.toMap(),
      where: "id = ?",
      whereArgs: [systemModel.id],
    );
  }

  Future<SystemModel> getSystem() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        SYSTEM_TABLE
    );
    return SystemModel.fromMap(maps.first);
  }
}
