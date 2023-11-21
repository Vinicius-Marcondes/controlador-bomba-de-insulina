import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/model/user_model.dart';
import 'package:controlador_bomba_de_insulina/repository/insulin_entry_dao.dart';
import 'package:controlador_bomba_de_insulina/repository/user_dao.dart';

class UserService {
  final UserDao userDao = UserDao();
  final InsulinEntryDao insulinEntryDao = InsulinEntryDao();

  Future<bool> createUser(final UserModel userModel) async {
    int result = await userDao.insertUser(userModel);

    if (result != 0) {
      return true;
    } else {
      throw Exception("Usuário não criado");
    }
  }

  Future<UserModel> getUser() async {
    return await userDao.getUser();
  }

  Future<void> updateUser(final UserModel userModel) async {
    await userDao.updateUser(userModel);
  }

  Future<List<InsulinEntryModel>> getInsulinEntries() async {
    return await insulinEntryDao.getAllEntries();
  }

  Future<InsulinEntryModel?> getLastInsulinEntry() async {
    List<InsulinEntryModel?> insulinEntries = await getInsulinEntries();
    insulinEntries.sort((a, b) => b!.timestamp.compareTo(a!.timestamp));
    return insulinEntries.first;
  }

  Future<List<InsulinEntryModel?>> getInsulinEntriesForInterval(DateTime start, DateTime end) async {
    DateTime newStart = DateTime(start.year, start.month, start.day, 0, 0, 1);
    DateTime newEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return await insulinEntryDao.retriveListForInterval(newStart, newEnd);
  }
}
