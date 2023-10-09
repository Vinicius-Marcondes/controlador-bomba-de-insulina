import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CharacteristicView extends StatefulWidget {
  const CharacteristicView({super.key, required this.service});

  final BluetoothService service;

  @override
  State<CharacteristicView> createState() => _CharacteristicViewState();
}

class _CharacteristicViewState extends State<CharacteristicView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.uuid.toString()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text('Características'),
            const Text('================'),
            Text(widget.service.characteristics[0].uuid.toString()),
            const Text('================'),
            Text(widget.service.characteristics[0].properties.toString()),
            const Text('================'),
            FutureBuilder<List<int>>(
              future: widget.service.characteristics[0].read(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.hasData) {
                  return Text( utf8.decode(snapshot.data!) );
                } else {
                  return const Text('Sem dados');
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                widget.service.characteristics[0].write(utf8.encode("180"));
              },
              child: const Text("Rotate servo"),
            )
          ],
        ),
      ),
    );
  }
}
