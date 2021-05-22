import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Thispensa/components/productWidgets/datePicker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Thispensa/components/productWidgets/flutterMobileVision.dart';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PaginaAggiuntaProdotto extends StatefulWidget {
  String barcode;
  String nomeProdotto;
  String urlImmagine;
  String calorie;
  String nutriScore;
  List<String> tracce;

  PaginaAggiuntaProdotto(this.barcode, this.nomeProdotto, this.urlImmagine,
      this.calorie, this.nutriScore, this.tracce);

  @override
  _PaginaAggiuntaProdottoState createState() => _PaginaAggiuntaProdottoState(
      barcode, nomeProdotto, urlImmagine, calorie, nutriScore, tracce);
}

class _PaginaAggiuntaProdottoState extends State<PaginaAggiuntaProdotto> {
  String barcode;
  String nomeProdotto;
  String urlImmagine;
  String calorie;
  String nutriScore;
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
      controllerData.text = stringa;
    });
  }

  _PaginaAggiuntaProdottoState(this.barcode, this.nomeProdotto,
      this.urlImmagine, this.calorie, this.nutriScore, this.tracce);

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
          Text(aaaaa),
          TextButton(
              child: Text("aggiungi"),
              onPressed: () async {
                //mando la chiamata
                String data = controllerData.text;
                int quantita = int.parse(controllerQuantita.text);
                print(data + " " + quantita.toString());
                Future<SharedPreferences> _prefs =
                    SharedPreferences.getInstance();
                final SharedPreferences prefs = await _prefs;
                String idDispensa = prefs.getString("idDispensa");
                var url =
                    "https://thispensa.herokuapp.com/inserisciProdottoDispensa";
                var params = {
                  "uid": _auth.currentUser.uid.toString(),
                  "tokenJWT": await _auth.currentUser.getIdToken(),
                  "nome": nomeProdotto,
                  "idDispensa": idDispensa,
                  "qta": quantita,
                  "dataScadenza": data,
                  "barcode": barcode
                };
                print(params);
                //? Richiesta post al server node con parametri
                http.post(Uri.parse(url), body: json.encode(params), headers: {
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
}
