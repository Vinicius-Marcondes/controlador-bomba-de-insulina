import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'characteristic_view.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final SystemService systemService = SystemService();

  BluetoothDevice? _connectedDevice;
  final List<BluetoothDevice> _devicesList = [];

  @override
  void initState() {
    super.initState();

    freeFlowBluetoothService.retrievePump().then((value) {
      _connectedDevice = value;
    });

    FlutterBluePlus.systemDevices.asStream().listen((List<BluetoothDevice> devices) {
      for (final BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }

      FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        for (final ScanResult result in results) {
          _addDeviceTolist(result.device);
        }
      });

      if (!FlutterBluePlus.isScanningNow) {
        FlutterBluePlus.startScan();
      }
    });

    return;
  }

  @override
  Widget build(BuildContext context) {
    return _buildView();
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  ListView _buildListViewOfDevices() {
    return ListView.builder(
      itemCount: _devicesList.length,
      itemBuilder: (BuildContext context, int index) {
        BluetoothDevice device = _devicesList[index];
        return ListTile(
          title: Text(device.platformName),
          subtitle: Text(device.remoteId.toString()),
          trailing: ElevatedButton(
            child: const Text('Conectar'),
            onPressed: () async {
              await device.connect();
              await device.createBond().then((value) async {
                await systemService.setPumpRemoteId(device.remoteId.toString());
                setState(() {
                  _connectedDevice = device;
                });
              });
            },
          ),
        );
      },
    );
  }

  ListView _buildConnectDeviceView() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ListTile(
          title: Text(_connectedDevice!.platformName),
          subtitle: Text(_connectedDevice!.remoteId.toString()),
          trailing: ElevatedButton(
            child: const Text('Desconectar'),
            onPressed: () async {
              await _connectedDevice!.removeBond();
              await _connectedDevice!.disconnect();
              setState(() {
                _connectedDevice = null;
              });
            },
          ),
        ),
        const Text("Services"),
        FutureBuilder(
          future: _connectedDevice!.discoverServices(),
          builder: (BuildContext context, AsyncSnapshot<List<BluetoothService>> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.map((service) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(service.uuid.toString()),
                        subtitle: Text(service.remoteId.toString()),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return CharacteristicView(service: service);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }).toList(),
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return const CircularProgressIndicator();
          },
        ),
      ],
    );
  }

  void _addDeviceTolist(final BluetoothDevice device) {
    if (!_devicesList.contains(device)) {
      setState(() {
        _devicesList.add(device);
      });
    }
  }
}
