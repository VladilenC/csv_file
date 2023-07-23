import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as dart_ui;
import '../models/gist.dart';

final GlobalKey<PlotState> chartKey = GlobalKey();

class Plot extends StatefulWidget {
  final List<Gist> items;
  final List<Gist> items2;

  const Plot({Key? key, required this.items, required this.items2})
      : super(key: key);

  @override
  PlotState createState() => PlotState();
}

class PlotState extends State<Plot> {
  final GlobalKey<PlotState> chartKey = GlobalKey();

  double maxSpeed = 0.0, minSpeed = 0.0, durationSpeed = 0.0;
  double maxSpeed2 = 0.0, minSpeed2 = 0.0, durationSpeed2 = 0.0;
  List<int> listPercent = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  List<int> listPercent2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();

    minSpeed = widget.items[0].speed;
    for (var element in widget.items) {
      if (element.speed > maxSpeed) {
        maxSpeed = element.speed;
      }
      if (element.speed < minSpeed) {
        minSpeed = element.speed;
      }
    }

    maxSpeed *= 1.01;
    durationSpeed = (maxSpeed - minSpeed) / 10;
    for (var element in widget.items) {
      for (int i = 0; i < 10; i++) {
        if (element.speed < (i + 1) * durationSpeed + minSpeed) {
          listPercent[i]++;
          break;
        }
      }
    }

    int count = 0;
    int len5 = widget.items.length;
    for (int i = 0; i < 10; i++) {
      if (listPercent[i] != 0) {
        count = i;
        break;
      }
    }

    int temp = 1;
    for (var element in widget.items) {
      if (temp == 1) {
        while (listPercent[count] == 0) {
          count++;
        }
        element.percent = (listPercent[count] / len5 * 1000).round() / 10;
        temp = listPercent[count];
      } else {
        temp--;
        continue;
      }
      count++;
      if (count >= 10) break;
    }

    minSpeed2 = widget.items2[0].speed;
    for (var element in widget.items2) {
      if (element.speed > maxSpeed2) {
        maxSpeed2 = element.speed;
      }
      if (element.speed < minSpeed2) {
        minSpeed2 = element.speed;
      }
    }
    maxSpeed2 *= 1.01;
    durationSpeed2 = (maxSpeed2 - minSpeed2) / 10;
    for (var element in widget.items2) {
      for (int i = 0; i < 10; i++) {
        if (element.speed < (i + 1) * durationSpeed2 + minSpeed2) {
          listPercent2[i]++;
          break;
        }
      }
    }

    count = 0;
    len5 = widget.items2.length;
    for (int i = 0; i < 10; i++) {
      if (listPercent2[i] != 0) {
        count = i;
        break;
      }
    }

    temp = 1;
    for (var element in widget.items2) {
      if (temp == 1) {
        while (listPercent2[count] == 0) {
          count++;
        }
        element.percent = (listPercent2[count] / len5 * 1000).round() / 10;
        temp = listPercent2[count];
      } else {
        temp--;
        continue;
      }
      count++;
      if (count >= 10) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: RepaintBoundary(
            key: chartKey,
            child: Center(
              child: Column(children: [
                Image.asset(
                  'assets/Pict.jpg',
                  height: 50,
                ),
                SizedBox(
                    width: 1000,
                    height: 400,
                    child: SfCartesianChart(
                        //            key: chartKey,
                        primaryXAxis: NumericAxis(),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        legend: const Legend(
                            isVisible: true, position: LegendPosition.bottom),
                        series: <ColumnSeries<Gist, double>>[
                          ColumnSeries<Gist, double>(
                              dataSource: widget.items,
                              xValueMapper: (Gist item, _) => item.time,
                              yValueMapper: (Gist item, _) => item.speed,
                              name: '5 секунд',
                              color: const Color.fromRGBO(102, 108, 192, 1),
                              trendlines: <Trendline>[
                                Trendline(
                                    type: TrendlineType.polynomial,
                                    width: 3,
                                    color:
                                        const Color.fromRGBO(102, 108, 192, 1),
                                    dashArray: <double>[15, 3, 3, 3],
                                    polynomialOrder: 4,
                                    period: 3,
                                    name: '5 сек среднее')
                              ]),
                          ColumnSeries<Gist, double>(
                              dataSource: widget.items2,
                              xValueMapper: (Gist item, _) => item.time,
                              yValueMapper: (Gist item, _) => item.speed,
                              name: '10 секунд',
                              color: const Color.fromRGBO(192, 108, 132, 1),
                              trendlines: <Trendline>[
                                Trendline(
                                    type: TrendlineType.polynomial,
                                    width: 3,
                                    color:
                                        const Color.fromRGBO(192, 108, 132, 1),
                                    dashArray: <double>[15, 3, 3, 3],
                                    polynomialOrder: 4,
                                    period: 3,
                                    name: '10 сек среднее')
                              ])
                        ])),
                Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                      SizedBox(
                          width: 500,
                          height: 400,
                          child: SfCartesianChart(
                              primaryXAxis: NumericAxis(
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  minimum: minSpeed,
                                  maximum: maxSpeed,
                                  interval: durationSpeed),
                              primaryYAxis: NumericAxis(
                                  //             minimum: 0,
                                  //              maximum: 10,
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines:
                                      const MajorTickLines(size: 0)),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              legend: const Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              series: <HistogramSeries<Gist, double>>[
                                HistogramSeries<Gist, double>(
                                  dataSource: widget.items,
                                  yValueMapper: (Gist item, _) => item.speed,
                                  name: '5 секунд',
                                  color: const Color.fromRGBO(102, 108, 192, 1),
                                  curveColor:
                                      const Color.fromRGBO(102, 108, 192, 1),
                                  showNormalDistributionCurve: true,
                                  binInterval: durationSpeed,
                                  curveDashArray: <double>[12, 3, 3, 3],
                                  width: 0.99,
                                  curveWidth: 2.5,
                                  dataLabelMapper: (Gist item, _) =>
                                      '${item.percent} %',
                                  dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      showZeroValue: false,
                                      labelAlignment:
                                          ChartDataLabelAlignment.top,
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ])),
                      SizedBox(
                          width: 500,
                          height: 400,
                          child: SfCartesianChart(
                              primaryXAxis: NumericAxis(
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  minimum: minSpeed2,
                                  maximum: maxSpeed2,
                                  interval: durationSpeed2),
                              primaryYAxis: NumericAxis(
                                  //             minimum: 0,
                                  //              maximum: 10,
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines:
                                      const MajorTickLines(size: 0)),
                              tooltipBehavior: TooltipBehavior(enable: true),
                              legend: const Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              series: <HistogramSeries<Gist, double>>[
                                HistogramSeries<Gist, double>(
                                  dataSource: widget.items2,
                                  yValueMapper: (Gist item, _) => item.speed,
                                  name: '10 секунд',
                                  color: const Color.fromRGBO(192, 108, 132, 1),
                                  curveColor:
                                      const Color.fromRGBO(192, 108, 132, 1),
                                  showNormalDistributionCurve: true,
                                  binInterval: durationSpeed2,
                                  curveDashArray: <double>[12, 3, 3, 3],
                                  width: 0.99,
                                  curveWidth: 2.5,
                                  dataLabelMapper: (Gist item, _) =>
                                      '${item.percent} %',
                                  dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      showZeroValue: false,
                                      labelAlignment:
                                          ChartDataLabelAlignment.top,
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                )
                              ]))
                    ]))
              ]),
            )));
  }

  Future<dart_ui.Image> convertToImage({double pixelRatio = 0.5}) async {
    final RenderRepaintBoundary boundary =
        context.findRenderObject() as RenderRepaintBoundary;
    final dart_ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    return image;
  }
}
