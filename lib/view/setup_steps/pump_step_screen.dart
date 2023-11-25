import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/invoke_reason.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:controlador_bomba_de_insulina/view/home.dart';
import 'package:controlador_bomba_de_insulina/widgets/pump_view_widget.dart';
import 'package:flutter/material.dart';

class PumpStepScreen extends StatefulWidget {
  final InvokeReason invokeReason;
  const PumpStepScreen({required this.invokeReason, super.key});

  @override
  State<PumpStepScreen> createState() => PumpStepScreenState();

  static PumpStepScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<PumpStepScreenState>();
  }
}

class PumpStepScreenState extends State<PumpStepScreen> {

  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final SystemService systemService = SystemService();

  bool _condition = false;

  set condition(final bool condition) => setState(() {
    _condition = condition;
  });

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
              SizedBox(
                height: constraints.maxHeight * 0.64,
                child: const PumpViewWidget(),
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
                            onPressed: _condition ? finishSetup : null,
                            child: const Text('Finalizar'),
                          ),
                          SizedBox(
                            height: constraints.maxHeight * 0.05,
                          ),
                          widget.invokeReason == InvokeReason.FIRST_TIME_USE ? const LinearProgressIndicator(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            minHeight: 10,
                            value: 1,
                          ) : Container(),
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
}
