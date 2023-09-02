import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  final String _paragraph = "O projeto 'FreeFlow Insulin Pump' nasceu com a visão de proporcionar uma mudança significativa na vida das pessoas que enfrentam o desafio da diabetes. O objetivo do projeto é desenvolver uma bomba de insulina de código aberto, sem fins lucrativos, que coloca o poder do gerenciamento da diabetes nas mãos dos próprios pacientes. Acreditamos firmemente na liberdade, na acessibilidade e na transparência. Com o 'FreeFlow Insulin Pump', buscamos capacitar indivíduos a viverem uma vida mais saudável e ativa, oferecendo uma solução inovadora e personalizável. Junte-se a nós nessa jornada para fazer a diferença na vida das pessoas com diabetes.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Text(
                'FreeFlow Insulin Pump',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                textAlign: TextAlign.justify,
                _paragraph,
              ),
              const Text(
                '© 2023 FreeFlow Insulin Pump',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
