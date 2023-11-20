import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/user_service.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
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
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: constraints.maxHeight * 0.5,
                width: constraints.maxWidth,
                child: Center(
                  child: _insulinEntries.isEmpty
                      ? const Text("Nenhuma entrada encontrada")
                      : ListView.builder(
                          itemCount: _insulinEntries.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 50,
                              color: index % 2 == 0 ? Colors.white : Colors.greenAccent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "${_insulinEntries[index].units}Ui",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    _insulinEntries[index].timestamp.toString(),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            );
                          },
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
            ],
          );
        }),
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
                      BuildContext? dialogContext;
                      FocusScope.of(context).unfocus();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          dialogContext = context;
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

                      await freeFlowBluetoothService.injectInsulin(textEditingController.text).then((value) {
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
