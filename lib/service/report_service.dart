import 'dart:io';

import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ReportService {

  Future<void> generateCSVFile(final List<InsulinEntryModel?> insulinEntries) async {

    if (insulinEntries.isEmpty) {
      throw Exception("Não há dados para gerar o relatório");
    }

    final DateFormat formatter = DateFormat('dd_MM_yyyy');
    final String? path = (await getDownloadsDirectory())?.path;
    List<Map<String, dynamic>> map = insulinEntries.map((e) => e!.toMap()).toList();

    // Convert List<Map<String,dynamic>> to List<List<<dynamic>>
    List<List<dynamic>> rows = [];
    for (var i = 0; i < map.length; i++) {
      List<dynamic> row = [];
      map[i].forEach((key, value) {
        row.add(value);
      });
      rows.add(row);
    }

    final String csv = const ListToCsvConverter().convert(rows, fieldDelimiter: ';', convertNullTo: '');

    final File file = File('$path/relatorio_${formatter.format(DateTime.now())}.csv');
    await file.writeAsString(csv);

    print("Relatório gerado");
  }
}
