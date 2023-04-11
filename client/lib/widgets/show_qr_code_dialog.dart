import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowQRCodeDialog extends StatelessWidget {
  const ShowQRCodeDialog({
    Key? key,
    required this.data,
  }) : super(key: key);
  final String data;

  Future<Uint8List?> _generateQr() async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        gapless: true,
        embeddedImageStyle: null,
        embeddedImage: null,
      );
      final picData = await painter.toImageData(2048);
      final buffer = picData!.buffer;

      return buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(data),
      content: FutureBuilder<Uint8List?>(
          future: _generateQr(),
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
                ? const CircularProgressIndicator()
                : snapshot.data == null
                    ? const Text('No Data')
                    : Image.memory(snapshot.data!);
          }),
    );
  }
}
