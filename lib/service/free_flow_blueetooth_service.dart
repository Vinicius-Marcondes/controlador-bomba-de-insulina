import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FreeFlowBluetoothService {
  // ignore: constant_identifier_names
  static const String PUMP_REMOTE_ID = "B0:A7:32:17:0A:C6";
  // ignore: constant_identifier_names
  static const String SERVICE_UUID = "f69317b5-a6b2-4cf4-89e6-9c7d98be8891";
  // ignore: constant_identifier_names
  static const String CHARACTERISTIC_UUID = "2ec829c3-efad-4ba2-8ce1-bad71b1040f7";

  static BluetoothDevice? _connectedDevice;
  static BluetoothCharacteristic? _characteristic;

  // Singleton instance
  static final FreeFlowBluetoothService _instance = FreeFlowBluetoothService._();

  // Private constructor
  FreeFlowBluetoothService._();

  // Factory constructor that returns the singleton instance
  factory FreeFlowBluetoothService() {
    return _instance;
  }

  Future<BluetoothDevice?> connect() async {
    _connectedDevice = await retrievePump();

    await _connectedDevice?.connect(autoConnect: true);
    List<BluetoothService> services = await _connectedDevice!.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            _characteristic = characteristic;
          }
        });
      }
    });
    print('Connected to pump');
    return _connectedDevice;
  }

  Future<BluetoothDevice?> retrievePump() async {
    List<BluetoothDevice?> devices = await FlutterBluePlus.bondedDevices;

    BluetoothDevice? device = devices.firstWhere(
        (element) => element?.remoteId.toString() == PUMP_REMOTE_ID,
        orElse: () => throw Exception("Pump not found"));

    return device;
  }

  BluetoothCharacteristic? getCharacteristic() {
    return _characteristic;
  }
}
