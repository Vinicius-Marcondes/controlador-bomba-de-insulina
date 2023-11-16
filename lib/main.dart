import 'package:controlador_bomba_de_insulina/repository/system_dao.dart';
import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/view/home.dart';
import 'package:controlador_bomba_de_insulina/view/setup_steps/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  [
    Permission.location,
    Permission.storage,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan
  ].request().then((status) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  final SystemDao systemDao = SystemDao();

  MyApp({super.key});

  // Application root
  @override
  Widget build(BuildContext context) {
    FreeFlowBluetoothService().connect();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors
            .lightGreen, // Define a cor da barra de status para a cor primária do tema
      ),
      child: MaterialApp(
        title: 'FreeFlow Insulin Pump Prototype',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: FutureBuilder<bool>(
          future: systemDao.isSystemInitialized(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator(); // Show loading spinner while waiting for db response
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.data!) {
                  return const HomePage(title: 'FreeFlow Insulin Pump');
                } else {
                  return const WelcomeScreen();
                }
              }
            }
          },
        ),
      ),
    );
  }
}
