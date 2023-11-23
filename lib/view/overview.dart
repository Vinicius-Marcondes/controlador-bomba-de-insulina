import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/model/user_model.dart';
import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final UserService userService = UserService();

  final TextEditingController insulinEditingController = TextEditingController();
  final TextEditingController carbsEditingController = TextEditingController();
  final TextEditingController glycemiaEditingController = TextEditingController();

  final _insulinInputKey = GlobalKey<FormState>();
  final List<InsulinEntryModel> _insulinEntries = [];

  int _suggestedUnits = 0;

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: FutureBuilder<UserModel>(
          future: userService.getUser(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Bem vindo');
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
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 480,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                      height: 90,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      child: _insulinEntries.isEmpty
                          ? null
                          : Text(
                              "Ultima dose aplicada: ${_insulinEntries.first.units}Ui",
                              style: const TextStyle(
                                fontSize: 25,
                                color: Colors.black54,
                              ),
                            )),
                  SizedBox(
                    height: 355,
                    width: 340,
                    child: _insulinEntries.isEmpty
                        ? const Center(
                            child: Text("Nenhuma insulina aplicada até o momento!"),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) {
                              return const Divider();
                            },
                            itemCount: _insulinEntries.length,
                            itemBuilder: (BuildContext context, int index) {
                              final DateFormat dateFormatter = DateFormat("hh:mm a - dd/MM/yy");
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                                leading: const Icon(Icons.medical_services_outlined),
                                title: Text(
                                  "${_insulinEntries[index].units}Ui",
                                  style: const TextStyle(fontSize: 18),
                                ),

                                trailing: Text(dateFormatter.format(_insulinEntries[index].timestamp), style: const TextStyle(fontSize: 16)),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }

  Future<void> _inputBuilder(final BuildContext context) {
    return showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          surfaceTintColor: Colors.white,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _insulinInputKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 115,
                            child: TextFormField(
                              controller: carbsEditingController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Carboidratos ingeridos',
                                labelText: 'Carboidratos',
                              ),
                              onChanged: (value) async {
                                final int suggestedUnits =
                                    await userService.calculateRecomendedAmoutOfInulinForCarbs(int.parse(carbsEditingController.text));
                                setState(() {
                                  if (carbsEditingController.text.isNotEmpty) {
                                    _suggestedUnits = suggestedUnits;
                                  }
                                });
                              },
                              validator: (value) {
                                if (value != null && value.isNotEmpty && int.parse(value) <= 0) {
                                  return 'Por favor, insira um valor maior que zero';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 115,
                            child: TextFormField(
                              controller: glycemiaEditingController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Glicemia atual',
                                labelText: 'Glicemia',
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty && int.parse(value) <= 0) {
                                  return 'Por favor, insira um valor maior que zero';
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      ),
                      TextFormField(
                        controller: insulinEditingController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          helperText: "Sugestão: ${_suggestedUnits.toString()} Ui",
                          hintText: 'Unidades de insulina',
                          labelText: 'Unidades de insulina',
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 75),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                                .injectInsulin(insulinEditingController.text, glicemia: convertGlycemia(glycemiaEditingController.text))
                                .then((value) {
                              userService.getInsulinEntries().then((value) => {
                                    setState(() {
                                      _insulinEntries.clear();
                                      _insulinEntries.addAll(value);
                                    })
                                  });
                            }).onError((error, stackTrace) {
                              print(">>>>>>>>>>>>>${error}");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Erro ao enviar insulina..."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }).whenComplete(() {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              insulinEditingController.clear();
                              carbsEditingController.clear();
                              glycemiaEditingController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  int? convertGlycemia(final String? glycemia) {
    if (glycemia == null || glycemia.isEmpty) {
      return null;
    } else {
      return int.parse(glycemia);
    }
  }
}
