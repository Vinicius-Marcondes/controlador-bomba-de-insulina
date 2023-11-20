import 'dart:convert';

import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/repository/insulin_entry_dao.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FreeFlowBluetoothService {
  static const String SERVICE_UUID = "f69317b5-a6b2-4cf4-89e6-9c7d98be8891";
  static const String INSULIN_CHARACTERISTIC_UUID = "2ec829c3-efad-4ba2-8ce1-bad71b1040f7";
  static const String PUMP_STATUS_CHARACTERISTIC_UUID = "1cd909de-3a8e-43e1-a492-82917ab0b662";

  static BluetoothDevice? _connectedDevice;

  // Singleton instance
  static final FreeFlowBluetoothService _instance = FreeFlowBluetoothService._();

  // Private constructor
  FreeFlowBluetoothService._();

  final SystemService systemService = SystemService();
  final InsulinEntryDao insulinEntryDao = InsulinEntryDao();

  // Factory constructor that returns the singleton instance
  factory FreeFlowBluetoothService() {
    return _instance;
  }

  Future<BluetoothDevice?> connect() async {
    _connectedDevice = await retrievePump();
    await _connectedDevice?.connect(timeout: const Duration(seconds: 15));
    return _connectedDevice;
  }

  Future<BluetoothDevice?> retrievePump() async {
    List<BluetoothDevice?> devices = await FlutterBluePlus.bondedDevices;
    String? pumpRemoteId = await systemService.getPumpRemoteId();

    if (pumpRemoteId == null) {
      throw Exception("Bomba não configurada");
    }

    BluetoothDevice? device = devices.firstWhere((element) => element?.remoteId.toString() == pumpRemoteId,
        orElse: () => throw Exception("Bomba não pareada"));

    return device;
  }

  Future<BluetoothDevice> getDevice() async {
    if (_connectedDevice == null || !_connectedDevice!.isConnected) {
      _connectedDevice = await connect();
    }

    return _connectedDevice!;
  }

  Future<BluetoothService> getService() async {
    BluetoothDevice device = await getDevice();
    List<BluetoothService> services = await device.discoverServices();
    return services.firstWhere((element) => element.uuid.toString() == SERVICE_UUID);
  }

  Future<BluetoothCharacteristic?> getCharacteristic(final String characteristicUuid) async {
    BluetoothService service = await getService();
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.uuid.toString() == characteristicUuid) {
        return characteristic;
      }
    }
    return null;
  }

  Future<bool> isPumpBusy() async {
    BluetoothCharacteristic? pumpStatusCharacteristic = await getCharacteristic(PUMP_STATUS_CHARACTERISTIC_UUID);
    List<int>? status = await pumpStatusCharacteristic?.read();
    String statusString = "";

    if (status == null) {
      throw Exception("Erro ao ler status da bomba");
    } else {
      statusString = utf8.decode(status);
    }

    return statusString == "1";
  }

  Future<void> injectInsulin(final String insulinAmount, {int? glicemia}) async {
    BluetoothCharacteristic? insulinCharacteristic = await getCharacteristic(INSULIN_CHARACTERISTIC_UUID);

    final bool pumpAvailable = await isPumpBusy() && (await systemService.isPumpLocked());
    if (!pumpAvailable) {
      throw Exception("Bomba ocupada");
    } else {
      await systemService.lockPump();
      await insulinCharacteristic
          ?.write(timeout: 120, utf8.encode(insulinAmount))
          .onError((error, stackTrace) => {print(stackTrace), throw Exception("Erro ao enviar insulina")});
      await insulinEntryDao.insertEntry(InsulinEntryModel(units: int.parse(insulinAmount), timestamp: DateTime.now(), glicemia: glicemia));
      await systemService.decreaseInsulinStock(int.parse(insulinAmount));
      await systemService.unlockPump();
    }
  }
}
