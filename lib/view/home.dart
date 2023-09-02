import 'package:controlador_bomba_de_insulina/view/Report.dart';
import 'package:controlador_bomba_de_insulina/view/overview.dart';
import 'package:controlador_bomba_de_insulina/view/settings.dart';
import 'package:flutter/material.dart';

import 'about.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int currentIndex = 0;
  NavigationDestinationLabelBehavior labelBehavior = NavigationDestinationLabelBehavior.alwaysShow;

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
        const Report(),
        Settings(),
        const About(),
      ][currentIndex],
    );
  }
}
