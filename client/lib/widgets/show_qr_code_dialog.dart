import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;

class MyCustomPainter extends CustomPainter {
  final ui.Image myBackground;
  final ui.Image qrImage;
  final String? tableNo;
  const MyCustomPainter(this.myBackground, this.qrImage, this.tableNo);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    canvas.drawImage(myBackground, const Offset(0.0, 0.0), paint);
    canvas.drawImage(qrImage, const Offset(60, 210), paint);
    canvas.drawCircle(
      const Offset(525, 810),
      37.5,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    if (tableNo != null) {
      TextSpan span = TextSpan(
          text: tableNo, style: const TextStyle(fontSize: 45, height: 1.0));
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout(minWidth: 75, maxWidth: 75);

      tp.paint(canvas, Offset(487.5, 810 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return oldDelegate.myBackground != myBackground ||
        oldDelegate.qrImage != qrImage;
  }
}

class ShowQRCodeDialog extends StatefulWidget {
  const ShowQRCodeDialog({
    Key? key,
    required this.data,
    this.tableNo,
  }) : super(key: key);
  final String data;
  final String? tableNo;

  @override
  State<ShowQRCodeDialog> createState() => _ShowQRCodeDialogState();
}

class _ShowQRCodeDialogState extends State<ShowQRCodeDialog> {
  Uint8List? _generated;

  Future<void> _generateQr() async {
    final result = await generateQrImage(
      widget.data,
      widget.tableNo,
    );
    setState(() {
      _generated = result!;
    });
  }

  downloadFile(String fileName, List<int> bytes) {
    final base64data = base64Encode(bytes);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = 'data:image/png;base64,$base64data'
      ..style.display = 'none'
      ..download = fileName;
    html.document.body?.children.add(anchor);

// download
    anchor.click();

// cleanup
    html.document.body?.children.remove(anchor);
    // html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SelectableText(widget.data),
      content: FutureBuilder(
          future: _generated == null ? _generateQr() : null,
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const CircularProgressIndicator()
                : _generated == null
                    ? const Text('No Data')
                    : Image.memory(_generated!);
          }),
      actions: [
        if (_generated != null)
          TextButton(
            onPressed: () {
              downloadFile('qr.png', _generated!.toList());
            },
            child: const Text('Download'),
          ),
      ],
    );
  }
}

Future<Uint8List?> generateQrImage(String data, String? tableNo) async {
  final qrValidationResult = QrValidator.validate(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );
  final byteData = await rootBundle.load('assets/qr-background.png');
  final imageCodec =
      await ui.instantiateImageCodec(byteData.buffer.asUint8List());
  final bgImage = (await imageCodec.getNextFrame()).image;
  if (qrValidationResult.status == QrValidationStatus.valid) {
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.circle,
        color: Colors.black,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.circle,
        color: Colors.black,
      ),
    );

    final qrImage = await painter.toImage(480);

    final myPainter = MyCustomPainter(bgImage, qrImage, tableNo);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    myPainter.paint(canvas, const Size(600, 900));
    final finalImg = await recorder.endRecording().toImage(600, 900);
    final buffer = await finalImg.toByteData(format: ui.ImageByteFormat.png);
    return buffer!.buffer.asUint8List();
  }
  return null;
}
