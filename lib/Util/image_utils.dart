import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static Future<Image> pickImage(final BuildContext context) async {
    final ImagePicker picker = ImagePicker();
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

    final XFile? selected = await picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (selected != null) {
      return Image.file(File(selected.path));
      // setState(() {
      //   _imageFile = selected;
      //   bytes = base64Encode(file.readAsBytesSync());
      // });
    } else {
      throw Exception("Imagem não selecionada");
    }
  }
}