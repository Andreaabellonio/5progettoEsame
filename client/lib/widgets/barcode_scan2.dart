import 'package:flutter/material.dart';
import 'dialog.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:translator/translator.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class Barcode extends StatefulWidget {
  Barcode({Key key}) : super(key: key);

  @override
  _BarcodeState createState() => _BarcodeState();
}

class _BarcodeState extends State<Barcode> {
  var nome = "";
  var qta = "";
  var allergie = "";
  var image;
  var scanBarcode = "";

  void _letturaDati(String codice) async {
    print("LETTURA DATI");
    print(codice);

    getProduct1(codice, "errore");
  }

  Future<void> getProduct1(barcode, messErrore) async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
        language: OpenFoodFactsLanguage.ITALIAN, fields: [ProductField.ALL]);
    ProductResult result = await OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      print("lettura dati");
      String nome = result.product.productName;
     ///int quantita = int.parse(result.product.quantity);
      String allergeni = result.product.allergens.toString();
      String urlImg = result.product.imgSmallUrl;
      print("dati letti");

      if (nome == "") nome = "errore";
     // if (quantita == null) quantita = 1;
      if (allergeni == null) allergeni = "non si sa";
      if (urlImg == null) urlImg = "non si sa";
      
      print("dialog");

      final action = await Dialogs.yesAbortDialog(
          context,
          nome,
          allergeni,
          urlImg,
          barcode);
      
    } else {
      _showMyDialog(context, messErrore);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _scansionaBarCode,
      child: Icon(Icons.add_a_photo),
      backgroundColor: Colors.red,
    );
  }

  void test() async {
    String testo = "HELLO WORLD";
    String testoTradotto = await traduci(testo);
    _showMyDialog(context, testoTradotto);
  }

  Future<String> traduci(String input) async {
    final translator = GoogleTranslator();
    var translation = await translator.translate(input, to: 'it');
    return translation.toString();
  }

  Future<void> _showMyDialog(BuildContext context, String testo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(testo)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
