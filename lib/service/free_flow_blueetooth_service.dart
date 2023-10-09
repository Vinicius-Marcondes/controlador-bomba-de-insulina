import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FreeFlowBluetoothService {
  // ignore: constant_identifier_names
  static const String PUMP_REMOTE_ID = "B0:A7:32:17:0A:C6";
  // ignore: constant_identifier_names
  static const String SERVICE_UUID = "f69317b5-a6b2-4cf4-89e6-9c7d98be8891";
  // ignore: constant_identifier_names
  static const String CHARACTERISTIC_UUID = "2ec829c3-efad-4ba2-8ce1-bad71b1040f7";

  Future<BluetoothDevice?> retrievePump() async {
    List<BluetoothDevice?> devices = await FlutterBluePlus.bondedDevices;

    BluetoothDevice? device = devices.firstWhere(
        (element) => element?.remoteId.toString() == PUMP_REMOTE_ID,
        orElse: () => throw Exception("Pump not found"));

    return device;
  }
}
