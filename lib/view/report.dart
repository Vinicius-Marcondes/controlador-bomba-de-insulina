
import 'package:controlador_bomba_de_insulina/model/insulin_entry_model.dart';
import 'package:controlador_bomba_de_insulina/service/report_service.dart';
import 'package:controlador_bomba_de_insulina/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final ReportService reportService = ReportService();
  final UserService userService = UserService();

  bool _showGlycemiaChart = true;
  int _radioButton = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Relatório"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          foregroundColor: Colors.white,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: SizedBox(
                    height: constraints.maxHeight * 0.45,
                    child: Column(
                      children: [
                        buildChart(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showGlycemiaChart = true;
                                });
                              },
                              child: const Text("Glicemia"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showGlycemiaChart = false;
                                });
                              },
                              child: const Text("Unidades aplicadas"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight * 0.4,
                  child: Column(
                    children: [
                      const Text(
                        "Exportar CSV",
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text("Último dia"),
                              Radio(
                                value: 0,
                                groupValue: _radioButton,
                                onChanged: (value) {
                                  setState(() {
                                    _radioButton = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Última semana"),
                              Radio(
                                value: 1,
                                groupValue: _radioButton,
                                onChanged: (value) {
                                  setState(() {
                                    _radioButton = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Último mês"),
                              Radio(
                                value: 2,
                                groupValue: _radioButton,
                                onChanged: (value) {
                                  setState(() {
                                    _radioButton = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: constraints.maxHeight * 0.075,
                      ),
                      Center(
                        child: ElevatedButton(
                            onPressed: () async {
                              final days = _radioButton == 0 ? 1 : _radioButton == 1 ? 7 : 30;
                              final DateTime startDate = DateTime.now().subtract(Duration(days: days));
                              final List<InsulinEntryModel?> insulinEntries = await userService.getInsulinEntriesForInterval(startDate, DateTime.now());
                              await reportService.generateCSVFile(insulinEntries).then((value) {
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Relatório gerado!",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    content: const Text("O relatório foi gerado e salvo na pasta Downloads do seu dispositivo.", textAlign: TextAlign.left,),
                                    actions: [
                                      Center(child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))),
                                    ],
                                  );
                                });
                              }).onError((error, stackTrace) {
                                showDialog(context: context, builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Erro ao gerar relatório!",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    content: const Text("Não foi possível gerar o relatório.", textAlign: TextAlign.left,),
                                    actions: [
                                      Center(child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))),
                                    ],
                                  );
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                              ),
                              minimumSize: Size(constraints.maxWidth * 0.95, 50),
                            ),
                            child: const Text("Salvar csv")),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  FutureBuilder<List<InsulinEntryModel>> buildChart() {
    return FutureBuilder<List<InsulinEntryModel>>(
      future: userService.getInsulinEntries(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Expanded(
            child: SfCartesianChart(
              title: (_showGlycemiaChart
                  ? ChartTitle(text: 'Histórico de glicema')
                  : ChartTitle(text: "Histórico de insulina aplicada")),
              primaryXAxis: DateTimeCategoryAxis(
                dateFormat: DateFormat('hh:mm'),
                isVisible: true,
                zoomFactor: 0.8,
              ),
              zoomPanBehavior: ZoomPanBehavior(
                enablePanning: true,
                zoomMode: ZoomMode.xy,
              ),
              series: <ChartSeries>[
                _showGlycemiaChart ? glycemiaSeries(snapshot) : insulinSeries(snapshot),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  LineSeries<InsulinEntryModel, DateTime> glycemiaSeries(final AsyncSnapshot<List<InsulinEntryModel>> snapshot) {
    final List<InsulinEntryModel> insulinEntries = snapshot.data!.where((element) => element.glicemia != null).toList();
    return LineSeries<InsulinEntryModel, DateTime>(
      dataSource: insulinEntries,
      xValueMapper: (InsulinEntryModel insulin, _) => insulin.timestamp,
      yValueMapper: (InsulinEntryModel insulin, _) => insulin.glicemia,
      sortFieldValueMapper: (InsulinEntryModel insulin, _) => insulin.timestamp,
      sortingOrder: SortingOrder.ascending,
      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        labelAlignment: ChartDataLabelAlignment.auto,
      ),
    );
  }

  LineSeries<InsulinEntryModel, DateTime> insulinSeries(final AsyncSnapshot<List<InsulinEntryModel>> snapshot) {
    return LineSeries<InsulinEntryModel, DateTime>(
      dataSource: snapshot.data!,
      xValueMapper: (InsulinEntryModel insulin, _) => insulin.timestamp,
      yValueMapper: (InsulinEntryModel insulin, _) => insulin.units,
      sortFieldValueMapper: (InsulinEntryModel insulin, _) => insulin.timestamp,
      sortingOrder: SortingOrder.ascending,
      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        labelAlignment: ChartDataLabelAlignment.auto,
      ),
    );
  }
}
