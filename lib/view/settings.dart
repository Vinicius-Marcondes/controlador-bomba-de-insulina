import 'dart:async';
import 'dart:convert';

import 'package:controlador_bomba_de_insulina/model/user_model.dart';
import 'package:controlador_bomba_de_insulina/service/free_flow_blueetooth_service.dart';
import 'package:controlador_bomba_de_insulina/service/system_service.dart';
import 'package:controlador_bomba_de_insulina/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FreeFlowBluetoothService freeFlowBluetoothService = FreeFlowBluetoothService();
  final SystemService systemService = SystemService();
  final UserService userService = UserService();

  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController bolusController = TextEditingController();
  final TextEditingController insulinRatioController = TextEditingController();

  String? _base64image;
  UserModel? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 500,
              width: double.infinity,
              child: Column(
                children: [
                  FutureBuilder<UserModel>(
                    future: userService.getUser(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        _user = snapshot.data!;
                        _base64image = _user!.image;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _pickImage,
                              icon: SizedBox(
                                width: 180,
                                height: 180,
                                child: ClipOval(
                                  child: _base64image != null
                                      ? Image.memory(base64Decode(_base64image!), fit: BoxFit.cover, frameBuilder:
                                          (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                                          if (wasSynchronouslyLoaded) {
                                            return child;
                                          }
                                          return AnimatedOpacity(
                                            opacity: frame == null ? 0 : 1,
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeOut,
                                            child: child,
                                          );
                                        })
                                      : Image.asset('assets/images/user.png', fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text(
                                "${_user!.firstName} ${_user!.lastName}",
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  height: 240,
                                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.lightGreen, width: 3),
                                    borderRadius: BorderRadius.circular(10),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: CustomScrollView(
                                    shrinkWrap: true,
                                    slivers: <Widget>[
                                      SliverList(
                                        delegate: SliverChildListDelegate(
                                          <Widget>[
                                            TextField(
                                              decoration: const InputDecoration(
                                                border: UnderlineInputBorder(),
                                                labelText: 'Nome',
                                              ),
                                              controller: nameController,
                                              onTap: () async {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text('Nome'),
                                                        content: TextField(
                                                          controller: nameController,
                                                          decoration: const InputDecoration(hintText: "Digite seu nome"),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text('Cancelar'),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text('Salvar'),
                                                            onPressed: () async {
                                                              if (nameController.text.isNotEmpty) {
                                                                _user!.firstName = nameController.text;
                                                                await userService.updateUser(_user!);
                                                                setState(() {});
                                                              }
                                                              nameController.clear();
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 50,
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                    color: Colors.white,
                                    child: const Text(
                                      'Dados pessoais',
                                      style: TextStyle(color: Colors.lightGreen, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 60,
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Adicione a lógica do botão aqui
                },
                child: Text('Configurar Bomba'),
              ),
            ),
          ],
        ),
      ),
    );
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

    if (selected != null) {
      final String bytes = (await selected.readAsBytes()).toString();
      setState(() {
        _base64image = bytes;
      });
    }
  }

  Image convertImage(final String encodedImage) {
    final decodedBytes = base64Decode(encodedImage);
    return Image(image: MemoryImage(decodedBytes));
  }
}
