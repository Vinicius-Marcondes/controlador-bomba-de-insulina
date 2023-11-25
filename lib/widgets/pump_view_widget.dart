import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:controlador_bomba_de_insulina/view/setup_steps/pump_step_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PumpViewWidget extends StatefulWidget {
  const PumpViewWidget({super.key});

  @override
  State createState() => _PumpViewWidgetState();
}

class _PumpViewWidgetState extends State<PumpViewWidget> {

  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final SystemService systemService = SystemService();

  BluetoothDevice? _connectedDevice;
  final List<BluetoothDevice> _devicesList = [];
  final List<Guid> _serviceList = [Guid(FreeFlowBluetoothService.SERVICE_UUID)];

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
        FlutterBluePlus.startScan(withServices: _serviceList);
      }
    });

    return;
  }

  @override
  Widget build(BuildContext context) {
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
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const PopScope(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );

              await device.connect();
              await device.createBond().then((value) async {
                await systemService.setPumpRemoteId(device.remoteId.toString());
                setState(() {
                  _connectedDevice = device;
                  PumpStepScreenState? father = PumpStepScreen.of(context);
                  if (father != null) {
                    father.condition = true;
                  }
                });
              }).whenComplete(() => Navigator.of(context).pop());
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
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const PopScope(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );

              await _connectedDevice!.connect().whenComplete(() async {
                await _connectedDevice!.removeBond().whenComplete(() {
                  setState(() {
                    _connectedDevice = null;
                  });
                  Navigator.of(context).pop();
                });
              });
            },
          ),
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