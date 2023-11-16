import 'dart:convert';

import 'package:controlador_bomba_de_insulina/repository/user_dao.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final UserDao userDao = UserDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: userDao.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Image image = Image.memory(base64Decode(snapshot.data![index].image!));
                return Column(
                  children: [
                    Image(image: image.image),
                    ListTile(
                      title: Text(snapshot.data![index].firstName),
                      subtitle: Text(snapshot.data![index].lastName),
                    )
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Something went wrong :(');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
