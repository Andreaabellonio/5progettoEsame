import 'package:flutter/material.dart';
import 'dialog.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:translator/translator.dart';



class AddBarcode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: (){},
      child: Icon(Icons.add_a_photo),
      backgroundColor: Colors.red,
    );
  }

/*
  Future<void> _scansionaBarCode() async {
    //? Funzione richiamata sul clic del pulsante
    String barcodeScanRes;
    RegExp exp = RegExp(r"(^[0-9]*$)"); //? regex per il controllo del barcode
    try {
      do {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Esci", true, ScanMode.BARCODE);
        print(barcodeScanRes);
      } while (!exp.hasMatch(barcodeScanRes));
    } on PlatformException {
      barcodeScanRes = 'Errore nello scanner di barcode';
    }
    if (!mounted) return;
    print(barcodeScanRes);
    await _letturaDati(barcodeScanRes);
  }


*/



}
