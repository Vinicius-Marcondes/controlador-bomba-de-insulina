import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/view/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PumpSettingsScreen extends StatefulWidget {
  const PumpSettingsScreen({super.key});

  @override
  State<PumpSettingsScreen> createState() => _PumpSettingsScreenState();
}

class _PumpSettingsScreenState extends State<PumpSettingsScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final FreeFlowBluetoothService freeFlowBluetoothService =
      FreeFlowBluetoothService();

  final List<BluetoothDevice> _devicesList = [];
  final List<Guid> serviceList = [Guid('f69317b5-a6b2-4cf4-89e6-9c7d98be8891')];

  bool condition = false;
  bool _isConnecting = false;
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();

    FlutterBluePlus.systemDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });

    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });

    if (!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan(withServices: serviceList, continuousUpdates: true);
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Bomba de insulina'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: constraints.maxHeight * 0.12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        'Para conectar a bomba de insulina, '
                        'ligue a bomba e aguarde até que a bomba seja '
                        'encontrada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: constraints.maxHeight * 0.64,
                child: _buildView(),
              ),
              Container(
                height: constraints.maxHeight * 0.24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              backgroundColor: Colors.white,
                              minimumSize: Size(constraints.maxWidth * 0.6, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: condition ? finishSetup : null,
                            child: const Text('Finalizar'),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
                          const LinearProgressIndicator(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            minHeight: 10,
                            value: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDevice();
    }
    return _buildListDevices();
  }

  ListView _buildListDevices() {
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
                  return WillPopScope(
                    onWillPop: () async => false,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              );

              await device.connect(autoConnect: true);
              await device.createBond();

              Navigator.of(context, rootNavigator: true).pop(); // Close the dialog

              setState(() {
                _connectedDevice = device;
                condition = true;
                _isConnecting = false;
              });
            },
          ),
        );
      },
    );
  }

  ListView _buildConnectDevice() {
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
      ],
    );
  }

  finishSetup() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            const HomePage(title: 'FreeFlow Insulin Pump'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var tween = Tween(begin: begin, end: end);
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!_devicesList.contains(device)) {
      setState(() {
        _devicesList.add(device);
      });
    }

    if (!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
