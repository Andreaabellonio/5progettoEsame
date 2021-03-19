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

    //var url = "http://93.41.224.64:13377/ricercaProdotto";
    var url = "http://10.0.100.117:13377/ricercaProdotto";

    var params = {"barcode": codice.toString()};
    http.post(Uri.encodeFull(url), body: json.encode(params), headers: {
      "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/json"
    }).then((response) async {
      var data = json.decode(response.body);
      var prodotto = data['prodotto'];
      // Map dati = jsonDecode(data[0]);

      if (data["trovato"]) {
        //c'è sul server percio non devo chiederlo a foodfacts
        //var datiProdotto = data["prodotto"];
        print(prodotto.product_name.toString());
        print(prodotto.traces.toString());
        final action = await Dialogs.yesAbortDialog(context,
            prodotto.product_name, prodotto.traces, prodotto.image_url, codice);
      } else {
        getProduct1(codice, "errore");
      }
    });
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
          context, nome, allergeni, urlImg, barcode);
    } else {
      _showMyDialog(context, messErrore);
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
