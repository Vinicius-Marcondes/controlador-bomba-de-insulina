// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/repository/insulin_entry_dao.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FreeFlowBluetoothService {
  static const String SERVICE_UUID = "f69317b5-a6b2-4cf4-89e6-9c7d98be8891";
  static const String INSULIN_CHARACTERISTIC_UUID = "2ec829c3-efad-4ba2-8ce1-bad71b1040f7";
  static const String PUMP_STATUS_CHARACTERISTIC_UUID = "1cd909de-3a8e-43e1-a492-82917ab0b662";
  static const String PUMP_STOCK_CHARACTERISTIC_UUID = "00324946-0c86-448e-b82b-ceb07b9e535e";

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

    if (_connectedDevice == null) {
      throw Exception("Bomba não pareada");
    }

    await _connectedDevice?.connect(timeout: const Duration(seconds: 15));

    final BluetoothCharacteristic characteristic = await getCharacteristic(PUMP_STATUS_CHARACTERISTIC_UUID);
    characteristic.setNotifyValue(true);

    final String status = utf8.decode(await characteristic.read());

    if (status == "0") {
      await systemService.unlockPump();
    }

    return _connectedDevice;
  }

  Future<BluetoothDevice?> retrievePump() async {
    BluetoothDevice? device;
    List<BluetoothDevice> devices = await FlutterBluePlus.bondedDevices;
    String? pumpRemoteId = await systemService.getPumpRemoteId();

    if (pumpRemoteId == null || pumpRemoteId.isEmpty) {
      return null;
    }

    for (final BluetoothDevice element in devices) {
      if (element.remoteId.toString() == pumpRemoteId) {
        device = element;
      }
    }

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

  Future<BluetoothCharacteristic> getCharacteristic(final String characteristicUuid) async {
    BluetoothService service = await getService();
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristic.uuid.toString() == characteristicUuid) {
        return characteristic;
      }
    }
    throw Exception("Característica não encontrada");
  }

  Future<bool> isPumpBusy() async {
    BluetoothCharacteristic? pumpStatusCharacteristic = await getCharacteristic(PUMP_STATUS_CHARACTERISTIC_UUID);
    List<int> status = await pumpStatusCharacteristic.read();
    String statusString = "";

    if (status.isEmpty) {
      throw Exception("Erro ao ler status da bomba");
    } else {
      statusString = utf8.decode(status);
    }

    return statusString == "1";
  }

  Future<bool> validatePumpStock() async {
    BluetoothCharacteristic? pumpStatusCharacteristic = await getCharacteristic(PUMP_STOCK_CHARACTERISTIC_UUID);
    List<int> status = await pumpStatusCharacteristic.read();
    String statusString = "";

    if (status.isEmpty) {
      throw Exception("Erro ao ler estoque da bomba");
    } else {
      statusString = utf8.decode(status);
    }

    return statusString == "1";
  }

  Future<void> injectInsulin(final String insulinAmount, {int? glicemia}) async {
    BluetoothCharacteristic? insulinCharacteristic = await getCharacteristic(INSULIN_CHARACTERISTIC_UUID);
    final int stockLeft = await systemService.stockLeft();
    final bool stockStatus = await validatePumpStock();

    final bool pumpBusy = await isPumpBusy();
    final bool isPumpLocked = await systemService.isPumpLocked();

    if (pumpBusy || isPumpLocked) {
      throw Exception("Bomba ocupada");
    } else if (stockLeft < int.parse(insulinAmount) || stockStatus) {
      throw Exception("Estoque insuficiente");
    } else {
      await systemService.lockPump();
      await insulinCharacteristic
          .write(timeout: 120, utf8.encode(insulinAmount))
          .onError((error, stackTrace) => throw Exception("Erro ao enviar insulina"));
      await insulinEntryDao.insertEntry(InsulinEntryModel(units: int.parse(insulinAmount), timestamp: DateTime.now(), glicemia: glicemia));
      await systemService.decreaseInsulinStock(int.parse(insulinAmount));
      await systemService.unlockPump();
      await getDevice().then((value) => value.disconnect());
    }
  }
}
