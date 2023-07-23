import 'dart:io';
import 'package:csv_file/models/gist.dart';
import 'package:csv_file/widgets/plot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:printing/printing.dart';
import 'dart:ui' as dart_ui;
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CSV скорость',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<dynamic>> _data = [];
  List<Gist> listGist5 = [];
  List<Gist> listGist10 = [];
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  double count5 = 0.0, count10 = 0.0;
  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _loadCSV() async {
    final rawData = await rootBundle.loadString("assets/test1.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

    _data = listData;

    double begin = _data[1][0], begin2 = _data[1][0];
    double sumTime = 0.0,
        sumSpeedTime = 0.0,
        speed = 0.0,
        sumTime2 = 0.0,
        sumSpeedTime2 = 0.0;

    double tempDuration = 0.0, tempTime = 0.0, tempTime2 = 0.0;

    for (int i = 2; i < _data.length; i++) {
      tempDuration = _data[i][0] - _data[i - 1][0];
      tempTime = _data[i][0] - begin;
      tempTime2 = _data[i][0] - begin2;
      if (tempTime2 < 10.0) {
        sumTime2 += tempDuration;
        sumSpeedTime2 += tempDuration * _data[i][3];

        if (tempTime < 5.0) {
          sumTime += tempDuration;
          sumSpeedTime += tempDuration * _data[i][3];
        } else {
          speed = sumTime > 0 ? sumSpeedTime / sumTime : 0.0;
          setState(() {
            listGist5
                .add(Gist(time: _data[i - 1][0], speed: speed, percent: 0));
            count5++;
          });

          begin = _data[i][0];
          sumTime = 0.0;
          sumSpeedTime = 0.0;
        }
      } else {
        speed = sumTime2 > 0 ? sumSpeedTime2 / sumTime2 : 0.0;
        setState(() {
          listGist10.add(Gist(time: _data[i - 1][0], speed: speed, percent: 0));
        });

        begin2 = _data[i][0];
        sumTime2 = 0.0;
        sumSpeedTime2 = 0.0;
      }
    }
  }

  void _printScreen() {
    Printing.layoutPdf(onLayout: (pdf.PdfPageFormat format) async {
      final doc = pw.Document();
      final image = await WidgetWrapper.fromKey(
        key: _printKey,
        pixelRatio: 2.0,
      );

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Test"),
        ),
        body: RepaintBoundary(
            key: _printKey,
            child: Center(
                child: listGist5.isNotEmpty
                    ? Plot(
                        key: chartKey,
                        items: listGist5,
                        items2: listGist10,
                      )
                    : Container())),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
                onPressed: () {
                  renderPdf();
                },
                child: const Icon(Icons.picture_as_pdf)),
            FloatingActionButton(
                onPressed: _printScreen, child: const Icon(Icons.print)),
          ],
        ));
  }

  Future<void> renderPdf() async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.orientation = PdfPageOrientation.landscape;

    final PdfBitmap bitmap = PdfBitmap(await _readImageData());
    document.pageSettings.margins.all = 0;
    document.pageSettings.size =
        Size(bitmap.width.toDouble(), bitmap.height.toDouble());
    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    page.graphics.drawImage(
        bitmap, Rect.fromLTWH(0, 0, pageSize.width, pageSize.height));

    final List<int> bytes = await document.save();
    document.dispose();
    Directory directory = (await getApplicationDocumentsDirectory());
    String path = directory.path;
    File file = File('$path/output.pdf');
    await file.writeAsBytes(bytes, flush: true);
    OpenFile.open('$path/output.pdf');
  }

  Future<List<int>> _readImageData() async {
    final dart_ui.Image data =
        await chartKey.currentState!.convertToImage(pixelRatio: 1.0);
    final ByteData? bytes =
        await data.toByteData(format: dart_ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }
}
