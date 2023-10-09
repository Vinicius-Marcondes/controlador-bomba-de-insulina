import 'package:controlador_bomba_de_insulina/router_b.dart';
import 'package:flutter/material.dart';

class RouteA extends StatefulWidget {
  const RouteA({super.key});

  @override
  State<StatefulWidget> createState() => _RouteAState();
}

class _RouteAState extends State<RouteA> {
  final TextEditingController textEditingController = TextEditingController();
  final List<String> _data = <String>[];

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route A'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_data[index]),
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              child: const Text('Open route B'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RouteB(data: _data)),
                );
              },
            ),
          ),
          Center(
            child: TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Insert data to be transfered',
              ),
              onSubmitted: (String value) {
                _addDataToList(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  _addDataToList(String data) {
    setState(() {
      _data.add(data);
    });
  }
}
