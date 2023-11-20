import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:controlador_bomba_de_insulina/model/user_model.dart';
import 'package:controlador_bomba_de_insulina/view/setup_steps/treatment_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  XFile? _imageFile;
  String? bytes;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final Completer<ImageSource> completer = Completer();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  completer.complete(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  completer.complete(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    final ImageSource source = await completer.future;

    final XFile? selected = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    File file = File(selected!.path);

    setState(() {
      _imageFile = selected;
      bytes = base64Encode(file.readAsBytesSync());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Perfil'),
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
                  height: constraints.maxHeight * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.05,
                      ),
                      IconButton(
                        onPressed: _pickImage,
                        icon: SizedBox(
                          width: constraints.maxWidth * 0.4,
                          height: constraints.maxWidth * 0.4,
                          child: ClipOval(
                            child: _imageFile != null
                                ? Image.file(File(_imageFile!.path),
                                    fit: BoxFit.cover, frameBuilder:
                                        (BuildContext context,
                                            Widget child,
                                            int? frame,
                                            bool wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) {
                                      return child;
                                    }
                                    return AnimatedOpacity(
                                      opacity: frame == null ? 0 : 1,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeOut,
                                      child: child,
                                    );
                                  })
                                : Image.asset('assets/images/user.png',
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: constraints.maxHeight * 0.01,
                      ),
                      const Text(
                        'Imagem de perfil',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: constraints.maxHeight * 0.65,
                  decoration: BoxDecoration(
                    // same colour as the primary colour of the project
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
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _firstNameController,
                                keyboardType: TextInputType.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Digite seu nome'),
                                        content: TextField(
                                          textCapitalization: TextCapitalization.sentences,
                                          controller: _firstNameController,
                                          autofocus: true,
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
                                    return 'Por favor, insira seu nome';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Sobrenome',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Digite seu sobrenome'),
                                        content: TextField(
                                          textCapitalization: TextCapitalization.sentences,
                                          controller: _lastNameController,
                                          autofocus: true,
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
                                    return 'Por favor, insira seu sobrenome';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _birthdateController,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Data de nascimento',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                onTap: () async {
                                  FocusScope.of(context).requestFocus(FocusNode());

                                  final DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    final String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                                    _birthdateController.text = formattedDate;
                                  }
                                },
                                validator: (value) {
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: constraints.maxHeight * 0.1,
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
                                  if (_formKey.currentState!.validate()) {
                                    UserModel userModel = UserModel(
                                      firstName: _firstNameController.text,
                                      lastName: _lastNameController.text,
                                      birthDate: _birthdateController.text,
                                      image: bytes,
                                    );

                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1,
                                                animation2) =>
                                            _imageFile != null ? TreatmentScreen(user: userModel, image: File(_imageFile!.path)) :  TreatmentScreen(user: userModel, image: null,),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var begin = const Offset(1.0, 0.0);
                                          var end = Offset.zero;
                                          var tween =
                                              Tween(begin: begin, end: end);
                                          var offsetAnimation =
                                              animation.drive(tween);
                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Avançar'),
                              )
                            ],
                          ),
                        ),
                        const LinearProgressIndicator(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          minHeight: 10,
                          value: 0.5,
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
