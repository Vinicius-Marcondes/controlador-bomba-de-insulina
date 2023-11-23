import 'package:controlador_bomba_de_insulina/model/system_model.dart';
import 'package:controlador_bomba_de_insulina/repository/system_dao.dart';

class SystemService {
  final SystemDao systemDao = SystemDao();

  Future<int> setSystemInitialized() async {
    final SystemModel systemModel = await systemDao.getSystem();
    systemModel.initialized = 1;
    return await systemDao.updateSystem(systemModel);
  }

  Future<bool> isSystemInitialized() async {
    SystemModel systemModel = await systemDao.getSystem();
    return systemModel.initialized == 1;
  }

  Future<String?> getPumpRemoteId() async {
     SystemModel systemModel = await systemDao.getSystem();
     return systemModel.pumpRemoteId;
  }

  Future<int> setPumpRemoteId(final String pumpRemoteId) async {
    final SystemModel systemModel = await systemDao.getSystem();
    systemModel.pumpRemoteId = pumpRemoteId;

    return await systemDao.updateSystem(systemModel);
  }

  Future<int> lockPump() async {
    final SystemModel systemModel = await systemDao.getSystem();
    systemModel.pumpLocked = 1;
    return await systemDao.updateSystem(systemModel);
  }

  Future<int> unlockPump() async {
    final SystemModel systemModel = await systemDao.getSystem();
    systemModel.pumpLocked = 0;
    return await systemDao.updateSystem(systemModel);
  }

  Future<bool> isPumpLocked() async {
    SystemModel systemModel = await systemDao.getSystem();
    return systemModel.pumpLocked == 1;
  }

  Future<int> updateInsulinStock(final int insulinStock) async {
    final SystemModel systemModel = await systemDao.getSystem();
    systemModel.insulinStock = insulinStock;
    return await systemDao.updateSystem(systemModel);
  }

  Future<int> decreaseInsulinStock(final int insulinStock) async {
    final SystemModel systemModel = await systemDao.getSystem();
    systemModel.insulinStock -= insulinStock;
    return await systemDao.updateSystem(systemModel);
  }

  Future<int> stockLeft() async {
    final SystemModel systemModel = await systemDao.getSystem();
    return systemModel.insulinStock;
  }
}