import 'package:controlador_bomba_de_insulina/service/invoke_reason.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:controlador_bomba_de_insulina/view/setup_steps/profile_screen.dart';
import 'package:controlador_bomba_de_insulina/view/setup_steps/pump_step_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  final SystemService systemService = SystemService();

  Widget? _nextScreen = const ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: constraints.maxHeight * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/image.png',
                      width: constraints.maxWidth * 0.8,
                      height: constraints.maxHeight * 0.5,
                    ),
                  ],
                ),
              ),
              Container(
                height: constraints.maxHeight * 0.5,
                decoration: BoxDecoration(
                  // same colour as the primary colour of the project
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Center(
                            child: Text(
                              'Bem-vindo ao FreeFlow',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Center(
                            child: Text(
                              'Nas próximas telas, você será guiado através do processo de configuração da sua bomba de insulina',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder(future: getNextPage(), builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _nextScreen = snapshot.data as Widget;
                        }
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                            backgroundColor: Colors.white,
                            minimumSize: Size(constraints.maxWidth * 0.6, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                _nextScreen!,
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                            );
                          },
                          child: const Text('Iniciar'),
                        );
                      }),
                      const LinearProgressIndicator(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        minHeight: 10,
                        value: 0.25,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<Widget> getNextPage() async {
    if (!(await systemService.isSystemInitialized())) {
      return const ProfileScreen();
    } else {
      return const PumpStepScreen(
          invokeReason: InvokeReason.PUMP_NOT_CONFIGURED);
    }
  }
}
