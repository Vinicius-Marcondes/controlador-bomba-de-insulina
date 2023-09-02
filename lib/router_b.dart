import 'package:flutter/material.dart';

class RouteB extends StatelessWidget {
  const RouteB({super.key, required this.data});

  final List<String> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Route B'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(data[index]),
                    );
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text('Return to route A',
                      textDirection: TextDirection.ltr),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ]));
  }
}
