import 'package:controlador_bomba_de_insulina/repository/system_dao.dart';
import 'package:controlador_bomba_de_insulina/view/overview.dart';
import 'package:controlador_bomba_de_insulina/view/settings.dart';
import 'package:controlador_bomba_de_insulina/view/setup_steps/pump_settings_screen.dart';
import 'package:flutter/material.dart';

import '../service/free_flow_blueetooth_service.dart';
import 'about.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final SystemDao systemDao = SystemDao();
  final FreeFlowBluetoothService freeFlowBluethoothService = FreeFlowBluetoothService();
  NavigationDestinationLabelBehavior labelBehavior = NavigationDestinationLabelBehavior.alwaysShow;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: labelBehavior,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Início',
            tooltip: 'Início',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.report),
            icon: Icon(Icons.report_gmailerrorred),
            label: 'Relatórios',
            tooltip: 'Relatórios',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Configurações',
            tooltip: 'Configurações',
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.question_answer),
              icon: Icon(Icons.question_answer_outlined),
              label: 'Sobre',
              tooltip: 'Sobre'),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: <Widget>[
        const Overview(),
        const PumpSettingsScreen(),
        const Settings(),
        const About(),
      ][currentIndex],
    );
  }
}
