import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thispensa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Thispensa'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var nome = "";
  var qta = "";
  var allergie = "";
  var image;
  var scanBarcode = "";

  void _letturaDati(String codice) async {
    print("LETTURA DATI");
    print(codice);
    var url = "http://192.168.1.53:13377/ricercaProdottoBarcode";
    var params = {"codice": codice.toString()};
    print(params);
    //? Richiesta post al server node con parametri
    http.post(Uri.encodeFull(url), body: json.encode(params), headers: {
      "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/json"
    }).then((response) async {
      //? Mappatura del json
      Map data = jsonDecode(response.body);
      //? Aggiornamento dati sull'applicazione
      print(data);
      if (data["errore"]) {
        print("ERRORE");
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
        setState(() {
          nome = nomeTradotto;
          qta = data["qta"] != null ? data["qta"] : "Non disponibile";
          allergie = tracceTradotto;
          image = data["urlImage"];
        });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nome: ',
            ),
            Text(
              '$nome',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Quantità: ',
            ),
            Text(
              '$qta',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Può contenere tracce di: ',
            ),
            Text(
              '$allergie',
              style: Theme.of(context).textTheme.headline4,
            ),
            Image.network('$image', fit: BoxFit.contain),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scansionaBarCode,
        tooltip: 'Scansiona barcode',
        child: Icon(Icons.qr_code_scanner),
      ),
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
