import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/model/user_model.dart';
import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/user_service.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  final FreeFlowBluetoothService freeFlowBluetoothService =
      FreeFlowBluetoothService();
  final TextEditingController textEditingController = TextEditingController();
  final UserService userService = UserService();

  final _insulinInputKey = GlobalKey<FormState>();
  final List<InsulinEntryModel> _insulinEntries = [];

  @override
  void initState() {
    super.initState();

    userService.getInsulinEntries().then((value) => {
          setState(() {
            _insulinEntries.clear();
            _insulinEntries.addAll(value);
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<UserModel>(
          future: userService.getUser(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return const Text(
                  'Bem vindo'); // Show loading spinner while waiting for db response
            } else {
              if (snapshot.hasError) {
                return const Text('Bem vindo');
              } else {
                return Text(
                  'Bem vindo, ${snapshot.data!.firstName}',
                );
              }
            }
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 480,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: FutureBuilder<InsulinEntryModel?>(
                    future: userService.getLastInsulinEntry(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          "Ultima dose aplicada: ${snapshot.data!.units}",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black54,
                          ),
                        );
                      } else {
                        return const Text("Nenuma entrada encontrada");
                      }
                    },
                  ),
                ),
                Container(
                  height: 355,
                  width: 340,
                  child: _insulinEntries.isEmpty
                      ? const Text("Nenhuma entrada encontrada")
                      : ListView.builder(
                          itemCount: _insulinEntries.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 0),
                                height: 50,
                                color: index % 2 == 0
                                    ? Theme.of(context).colorScheme.background
                                    : Colors.green[50],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "${_insulinEntries[index].units}Ui",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      _insulinEntries[index]
                                          .timestamp
                                          .toString(),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 5.0,
                  backgroundColor: Theme.of(context).colorScheme.background,
                  minimumSize: const Size(300, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              child: const Text('Injetar Insulina',
                  style: TextStyle(
                    fontSize: 18,
                  )),
              onPressed: () => _inputBuilder(context),
            ),
          ),
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
            borderRadius: BorderRadius.circular(10.0),
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
                      if (value == null || value.isEmpty || value == "") {
                        return 'Por favor, insira um valor';
                      }
                      if (int.parse(value) > 50 || int.parse(value) <= 0) {
                        return 'Por favor, insira um valor entre 1 e 50';
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
                    if (_insulinInputKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const PopScope(
                            canPop: false,
                            child: SizedBox(
                              height: 100,
                              width: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      await freeFlowBluetoothService
                          .injectInsulin(textEditingController.text)
                          .then((value) {
                        userService.getInsulinEntries().then((value) => {
                              setState(() {
                                _insulinEntries.clear();
                                _insulinEntries.addAll(value);
                              })
                            });
                      }).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Erro ao enviar insulina..."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }).whenComplete(() {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
                      textEditingController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
