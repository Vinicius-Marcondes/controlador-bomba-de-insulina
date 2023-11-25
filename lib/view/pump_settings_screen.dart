import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:controlador_bomba_de_insulina/widgets/pump_view_widget.dart';
import 'package:flutter/material.dart';

class PumpSettingsScreen extends StatefulWidget {
  const PumpSettingsScreen({super.key});

  @override
  State<PumpSettingsScreen> createState() => PumpSettingsScreenState();
}

class PumpSettingsScreenState extends State<PumpSettingsScreen> {
  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final SystemService systemService = SystemService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bomba de insulina'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          foregroundColor: Colors.white,
        ),
        body: LayoutBuilder(builder: (final BuildContext context, final BoxConstraints constraints) {
          return Column(
            children: [
              SizedBox(
                height: constraints.maxHeight * 0.7,
                child: const PumpViewWidget(),
              ),
              Container(
                height: constraints.maxHeight * 0.3,
                width: constraints.maxWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SizedBox(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(constraints.maxWidth * 0.7, constraints.maxHeight * 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {freeFlowBluetoothService.refillPump();},
                    child: const Text('Recarregar estoque'),
                  ) ,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
