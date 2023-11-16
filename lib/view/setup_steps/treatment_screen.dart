import 'dart:io';

import 'package:controlador_bomba_de_insulina/model/user_model.dart';
import 'package:controlador_bomba_de_insulina/repository/system_dao.dart';
import 'package:controlador_bomba_de_insulina/repository/user_dao.dart';
import 'package:controlador_bomba_de_insulina/view/setup_steps/pump_settings_screen.dart';
import 'package:flutter/material.dart';

class TreatmentScreen extends StatefulWidget {
  final UserModel user;
  final File? image;

  const TreatmentScreen({required this.user, required this.image, Key? key})
      : super(key: key);

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  final _treatmentFormKey = GlobalKey<FormState>();

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _basalInsulinController = TextEditingController();
  final TextEditingController _insulinRateController = TextEditingController();

  final UserDao userDao = UserDao();
  final SystemDao systemDao = SystemDao();

  final List<String> _diabetesTypes = [
    'Tipo 1',
    'Tipo 2',
    'LADA',
    'Gestacional'
  ]; // Adicione os tipos de diabetes que você precisa
  String? _selectedDiabetesType;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Tratamento'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: constraints.maxHeight * 0.30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.05,
                      ),
                      SizedBox(
                        height: constraints.maxWidth * 0.4,
                        width: constraints.maxWidth * 0.4,
                        child: ClipOval(
                          child: widget.image != null
                              ? Image.file(
                                  widget.image!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset('assets/images/user.png',
                                  fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: constraints.maxHeight * 0.7,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Form(
                          key: _treatmentFormKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _heightController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Altura (cm)',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Insira sua altura (cm)'),
                                        content: TextField(
                                          controller: _heightController,
                                          autofocus: true,
                                          keyboardType: TextInputType.number,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira sua altura';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _weightController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Peso (Kg)',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Insira seu peso (Kg)'),
                                        content: TextField(
                                          controller: _weightController,
                                          autofocus: true,
                                          keyboardType: TextInputType.number,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu peso';
                                  }
                                  return null;
                                },
                              ),
                              DropdownButtonFormField<String>(
                                style: const TextStyle(
                                  color: Colors
                                      .black, // Cor do texto antes da seleção
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Tipo de Diabetes',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                value: _selectedDiabetesType,
                                items: _diabetesTypes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                selectedItemBuilder: (BuildContext context) {
                                  return _diabetesTypes
                                      .map<Widget>((String value) {
                                    return Text(value,
                                        style: const TextStyle(
                                            color: Colors
                                                .white)); // Cor do texto após a seleção
                                  }).toList();
                                },
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedDiabetesType = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, selecione seu tipo de diabetes';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _basalInsulinController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Insulina Basal',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Insira sua quantidade de insulina basal'),
                                        content: TextField(
                                          controller: _basalInsulinController,
                                          autofocus: true,
                                          keyboardType: TextInputType.number,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira sua insulina basal';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _insulinRateController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Fator de Correção',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                keyboardType: TextInputType.number,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Insira seu fator de correção (ui/g)'),
                                        content: TextField(
                                          controller: _insulinRateController,
                                          autofocus: true,
                                          keyboardType: TextInputType.number,
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu fator de correção';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: constraints.maxHeight * 0.036,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  backgroundColor: Colors.white,
                                  minimumSize:
                                      Size(constraints.maxWidth * 0.6, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  if (_treatmentFormKey.currentState!
                                      .validate()) {
                                    widget.user.height =
                                        double.parse(_heightController.text);
                                    widget.user.weight =
                                        double.parse(_weightController.text);
                                    widget.user.diabetesType =
                                        _selectedDiabetesType;
                                    widget.user.basalInsulin = double.parse(
                                        _basalInsulinController.text);
                                    widget.user.insulinRate = double.parse(
                                        _insulinRateController.text);

                                    userDao
                                        .insertUser(widget.user)
                                        .whenComplete(
                                          () => systemDao
                                              .setSystemInitialized()
                                              .whenComplete(
                                                () => Navigator.push(
                                                  context,
                                                  PageRouteBuilder(
                                                    pageBuilder: (context,
                                                            animation1,
                                                            animation2) =>
                                                        const PumpSettingsScreen(),
                                                    transitionsBuilder:
                                                        (context,
                                                            animation,
                                                            secondaryAnimation,
                                                            child) {
                                                      var begin = const Offset(
                                                          1.0, 0.0);
                                                      var end = Offset.zero;
                                                      var tween = Tween(
                                                          begin: begin,
                                                          end: end);
                                                      var offsetAnimation =
                                                          animation
                                                              .drive(tween);
                                                      return SlideTransition(
                                                        position:
                                                            offsetAnimation,
                                                        child: child,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                        );
                                  }
                                },
                                child: const Text('Avançar'),
                              ),
                            ],
                          ),
                        ),
                        const LinearProgressIndicator(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          minHeight: 10,
                          value: 0.75,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
