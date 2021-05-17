import 'package:flutter/material.dart';
import 'package:client/widgets/datePicker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:client/widgets/flutterMobileVision.dart';
import 'dart:convert';
import 'dart:io';

class PaginaAggiuntaProdotto extends StatefulWidget {
  String barcode;
  String nomeProdotto;
  String urlImmagine;
  String calorie;
  String nutriScore;
  String ingredienti;
  String qta;
  List<String> tracce;

  PaginaAggiuntaProdotto(this.barcode, this.nomeProdotto, this.urlImmagine,
      this.calorie, this.nutriScore, this.tracce, this.ingredienti, this.qta);

  @override
  _PaginaAggiuntaProdottoState createState() => _PaginaAggiuntaProdottoState(
      barcode,
      nomeProdotto,
      urlImmagine,
      calorie,
      nutriScore,
      tracce,
      ingredienti,
      qta);
}

class _PaginaAggiuntaProdottoState extends State<PaginaAggiuntaProdotto> {
  String barcode;
  String nomeProdotto;
  String urlImmagine;
  String calorie;
  String nutriScore;
  String ingredienti;
  String qta;
  List<String> tracce;
  String aaaaa = "aaa";

  var controllerQuantita = TextEditingController();
  var controllerData = TextEditingController();

  callback(nuovoController) {
    setState(() {
      controllerData = nuovoController;
    });
  }

  callback2(stringa) {
    setState(() {
      if (stringa != "")
        controllerData.text = DateTime.parse(stringa).toString().split(' ')[0];
      else {
        controllerData.text = "";
        _showMyDialog(context, "Data non riconosciuta.\nRiprovare");
      }
    });
  }

  _PaginaAggiuntaProdottoState(
      this.barcode,
      this.nomeProdotto,
      this.urlImmagine,
      this.calorie,
      this.nutriScore,
      this.tracce,
      this.ingredienti,
      this.qta);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Aggiungi Prodotto"),
        ),
        body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
          Container(
            child: Text(
              nomeProdotto,
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Container(
            child: Text(
              "NutriScore: " + nutriScore,
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Container(
            child: Text(
              "calorie: " + calorie,
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Container(
            child: Text(
              "Ingredienti: " + ingredienti,
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Text("puo contenere tracce di:"),
          ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: tracce.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  child: Center(child: Text('${tracce[index]}')),
                );
              }),
          MobileVision(callback2),
          Container(
            child: DatePicker(controllerData, callback),
            padding: EdgeInsets.all(16.0),
          ),
          Container(
              child: TextField(
                  controller: controllerQuantita,
                  decoration:
                      new InputDecoration(labelText: "Enter your number"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ]),
              padding: EdgeInsets.all(16.0)),
          Image.network('$urlImmagine', fit: BoxFit.contain),
          TextButton(
              child: Text("aggiungi"),
              onPressed: () {
                //mando la chiamata
                String data = controllerData.text;
                int quantita = int.parse(controllerQuantita.text);
                print(data + " " + quantita.toString());
                var url = "http://93.41.224.64:13377";
                var params = {
                  "idUtente": "60491b3739c4c1f0512d0c38",
                  "idDispensa": "60491bb339c4c1f0512d0c3a",
                  "qta": quantita,
                  "dataScadenza": data,
                  "barcode": barcode
                };
                print(params);
                //? Richiesta post al server node con parametri
                http.post(Uri.http(url, "/inserisciProdottoDispensa"),
                    body: json.encode(params),
                    headers: {
                      "Accept": "application/json",
                      HttpHeaders.contentTypeHeader: "application/json"
                    }).then((response) async {
                  Map data = jsonDecode(response.body);

                  if (data["errore"])
                    print("NOOOOOOOOOOOOOOOOOOOOOOOo");
                  else
                    print("fattoooo");

                  Navigator.of(context).pop();
                });
              }),
          TextButton(
              child: Text("annulla"),
              onPressed: () {
                //navigation.pop
                Navigator.of(context).pop();
              }),
        ]));
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
