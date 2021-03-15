import 'package:flutter/material.dart';
import 'dialog.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:translator/translator.dart';

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
    var url = "http://93.41.224.64:13377/ricercaProdotto";
    var params = {"barcode": codice.toString()};
    print(params);
    //? Richiesta post al server node con parametri
    http.post(Uri.encodeFull(url), body: json.encode(params), headers: {
      "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/json"
    }).then((response) async {
      //? Mappatura del json
      print(response.body);
      Map data = jsonDecode(response.body);
      //? Aggiornamento dati sull'applicazioner
      print(data);
      if (data["errore"]) {
        print("ERRORE");
        //TODO: faccio la chiamata a foodfacts

        _showMyDialog(context, data["messaggioErrore"]);
      } else {
        String nomeTradotto = "";
        List<String> nomeSplit = data["nome"].split(' ').toList();
        if (nomeSplit.length > 2) {
          print("TRADUZIONE NOME");
          nomeTradotto = await traduci(data["nome"]);
        } else {
          nomeTradotto = data["nome"];
        }
        String tracceTradotto = "";
        if (data["tracce"] != null) {
          print("TRADUZIONE TRACCE");
          tracceTradotto = await traduci(data["tracce"]);
        }

        final action = await Dialogs.yesAbortDialog(
            context,
            nomeTradotto,
            data["qta"] != null ? data["qta"] : "Non disponibile",
            tracceTradotto,
            data["urlImage"],
            codice);
      }
    });
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
