import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:translator/translator.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:client/screens/paginaAggiuntaProdotto/paginaAggiuntaProdotto.dart';

class Barcode extends StatefulWidget {
  Barcode({Key key}) : super(key: key);

  @override
  _BarcodeState createState() => _BarcodeState();
}

class _BarcodeState extends State<Barcode> {
  void _letturaDati(String codice) async {
    print("LETTURA DATI");
    print(codice);

    //funzione che prende il codice usa l'api che crea la scheda di aggiunta
    getProduct1(codice);
  }

  Future<void> getProduct1(barcode) async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
        language: OpenFoodFactsLanguage.ITALIAN, fields: [ProductField.ALL]);
    ProductResult result = await OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      String nome = result.product.productName;
      String urlImg = result.product.imgSmallUrl;
      String calorie = result.product.nutrimentEnergyUnit == null
          ? "Non disponibile per questo prodotto"
          : result.product.nutrimentEnergyUnit;
      String nutriScore = result.product.nutriscore == null
          ? "Non disponibile per questo prodotto"
          : result.product.nutriscore;
      List<String> tracce = result.product.tracesTags;

      print(calorie);
      print(nutriScore);
      print(tracce);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PaginaAggiuntaProdotto(barcode,nome, urlImg, calorie, nutriScore, tracce),
        ),
      );
    }
  }

  Future<void> _scansionaBarCode() async {
    //? Funzione richiamata sul clic del pulsante
    String barcodeScanRes;
    RegExp exp = RegExp(r"(^[0-9]*$)"); //? regex per il controllo del barcode
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Esci", true, ScanMode.BARCODE);
      print(barcodeScanRes);
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
      backgroundColor: Colors.blue,
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
