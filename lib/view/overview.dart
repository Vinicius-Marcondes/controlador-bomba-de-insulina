import 'dart:convert';

import 'package:controlador_bomba_de_insulina/repository/generic_dao.dart';
import 'package:controlador_bomba_de_insulina/repository/user_dao.dart';
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
  final UserDao userDao = UserDao();

  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final TextEditingController textEditingController = TextEditingController();

  final _insulinInputKey = GlobalKey<FormState>();
  final List<List<String>> _dummyInsulinLog = [];

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;

  @override
  void initState() {
    super.initState();
    freeFlowBluetoothService.connect();
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
      Text(_connectedDevice?.platformName ?? "Nenhum dispositivo conectado"),
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
                    onPressed: () async {
                      var device = await freeFlowBluetoothService.retrievePump();
                      var characteristic = freeFlowBluetoothService.getCharacteristic();
                      setState(() {
                        _connectedDevice = device;
                        if (characteristic != null) {
                          _characteristic = characteristic;
                        }
                      });

                      _characteristic?.write(utf8.encode('50')).whenComplete(() => _addDataToList(textEditingController.text, textEditingController));

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
