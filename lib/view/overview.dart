import 'dart:convert';

import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final TextEditingController textEditingController = TextEditingController();

  final _insulinInputKey = GlobalKey<FormState>();
  final List<List<String>> _dummyInsulinLog = [];

  BluetoothDevice? _connectedDevice;
  late final BluetoothCharacteristic _characteristic;

  @override
  void initState() {
    super.initState();
    freeFlowBluetoothService.retrievePump().then((value) => setState(() {
      setState(() {
        _connectedDevice = value;
      });
      _connectedDevice?.connect().then((value) => {
        _connectedDevice?.discoverServices().then((services) => {
          services.forEach((service) {
            if (service.uuid.toString() == "f69317b5-a6b2-4cf4-89e6-9c7d98be8891") {
              service.characteristics.forEach((characteristic) {
                if (characteristic.uuid.toString() == "2ec829c3-efad-4ba2-8ce1-bad71b1040f7") {
                  _characteristic = characteristic;
                }
              });
            }
          })
        })
      });
    })).catchError((_) => _connectedDevice = null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Center(
                child: _dummyInsulinLog.isEmpty
                    ? const Text("Nenhuma entrada encontrada")
                    : ListView.builder(
                        itemCount: _dummyInsulinLog.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: const EdgeInsets.all(35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("${_dummyInsulinLog[index][1]}Ui"),
                                Text(_dummyInsulinLog[index][0]),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 75),
            ),
            child: const Text('Injetar Insulina'),
            onPressed: () => _inputBuilder(context),
          ),
      Text(_connectedDevice?.localName ?? "Nenhum dispositivo conectado"),
        ],
      ),
    );
  }

  Future<void> _inputBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            surfaceTintColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Form(
                    key: _insulinInputKey,
                    child: TextFormField(
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Insira a quantidade de insulina',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um valor';
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      maximumSize: const Size(200, 100),
                    ),
                    child: const Text('Confimar'),
                    onPressed: () {
                      if (_insulinInputKey.currentState!.validate()) {
                        if (_connectedDevice != null) {
                          int input = int.parse(textEditingController.text) * 5;
                          _characteristic.write(utf8.encode(input.toString())).then((value) => {
                            _addDataToList(textEditingController.text, textEditingController)
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enviando para a bomba...'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erro ao enviar para a bomba!'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _addDataToList(String data, TextEditingController textEditingController) {
    setState(() {
      _dummyInsulinLog.add([
        DateFormat("HH:mm - dd/MM/yyyy").format(DateTime.now()).toString(),
        data
      ]);
    });
    textEditingController.clear();
  }
}
