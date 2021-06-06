import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:http/http.dart' as http;
import 'package:numberpicker/numberpicker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thispensa/components/productWidgets/barcode_scan2.dart';
import 'package:thispensa/components/productWidgets/datePicker.dart';
import 'package:thispensa/components/productWidgets/flutterMobileVision.dart';
import 'package:thispensa/styles/colors.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PaginaAggiuntaProdotto extends StatefulWidget {
  String barcode = "";
  String nomeProdotto = "";
  String urlImmagine = "";
  String calorie = "";
  String nutriScore = "Non disponibile per questo prodotto";
  List<String> tracce = [];
  bool manuale = true;
  final _callback;

  PaginaAggiuntaProdotto(
      {this.barcode,
      this.nomeProdotto,
      this.urlImmagine,
      this.calorie,
      this.nutriScore,
      this.tracce,
      void refresh()})
      : _callback = refresh;

  @override
  _PaginaAggiuntaProdottoState createState() => _PaginaAggiuntaProdottoState();
}

class _PaginaAggiuntaProdottoState extends State<PaginaAggiuntaProdotto> {
  var controllerData = TextEditingController();
  int _currentHorizontalIntValue = 1;

  @override
  void initState() {
    if (widget.barcode != "") widget.manuale = false;
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
        floatingActionButton: Barcode(widget._callback),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    background: (widget.urlImmagine != "")
                        ? Image.network(widget.urlImmagine, fit: BoxFit.contain)
                        : Image.asset("assets/foodPhoto.png")),
              ),
            ];
          },
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Prodotto',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: TextFormField(
                                style: TextStyle(fontSize: 18.0),
                                decoration: InputDecoration(
                                  labelText: 'Nome prodotto',
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                                validator: (input) => input.trim().isEmpty
                                    ? 'Inserisci il nome del prodotto'
                                    : null,
                                onSaved: (input) => widget.nomeProdotto = input,
                                initialValue: widget.nomeProdotto,
                              ),
                            ),
                            (widget.nutriScore !=
                                    "Non disponibile per questo prodotto")
                                ? Padding(
                                    child: SvgPicture.network(
                                      'https://static.openfoodfacts.org/images/misc/nutriscore-' +
                                          widget.nutriScore +
                                          '.svg',
                                      placeholderBuilder:
                                          (BuildContext context) => Container(
                                              padding:
                                                  const EdgeInsets.all(30.0),
                                              child:
                                                  const CircularProgressIndicator()),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                  )
                                : SizedBox(height: 0),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: TextFormField(
                                initialValue: widget.calorie,
                                keyboardType: TextInputType.number,
                                enabled: (widget.manuale) ? true : false,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                  disabledBorder: (widget.manuale)
                                      ? OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))
                                      : UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38)),
                                  labelText: 'Calorie',
                                  labelStyle: TextStyle(
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            ),
                            (widget.tracce[0] !=
                                    "Non disponibile per questo prodotto")
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Può contentere tracce di:',
                                            style: TextStyle(fontSize: 18)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Container(
                                            child: ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                itemCount: widget.tracce.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    //height: 18,
                                                    child: Column(children: [
                                                      ListTile(
                                                        leading: Icon(
                                                            Icons
                                                                .fiber_manual_record,
                                                            color: Colori
                                                                .primario),
                                                        title: new Text(
                                                            '${widget.tracce[index]}'),
                                                      ),
                                                    ]),
                                                  );
                                                }),
                                          ),
                                        ),
                                      ],
                                    ))
                                : SizedBox(
                                    height: 0,
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: DatePicker(controllerData, callback),
                                ),
                                MobileVision(callback2),
                              ],
                            ),
                            SizedBox(
                              height: 35,
                            ),
                            NumberPicker(
                              value: _currentHorizontalIntValue,
                              minValue: 1,
                              maxValue: 100,
                              step: 1,
                              itemHeight: 70,
                              itemWidth: 70,
                              axis: Axis.horizontal,
                              onChanged: (value) => setState(
                                  () => _currentHorizontalIntValue = value),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => setState(() {
                                    if (_currentHorizontalIntValue > 1) {
                                      final newValue =
                                          _currentHorizontalIntValue - 1;
                                      _currentHorizontalIntValue =
                                          newValue.clamp(0, 100);
                                    }
                                  }),
                                ),
                                Text('Quantità Prodotto'),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => setState(() {
                                    if (_currentHorizontalIntValue < 100) {
                                      final newValue =
                                          _currentHorizontalIntValue + 1;
                                      _currentHorizontalIntValue =
                                          newValue.clamp(0, 100);
                                    }
                                  }),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 20.0),
                              height: 60.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colori.primarioScuro,
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: TextButton(
                                  child: Text(
                                    'Aggiungi Prodotto',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                  onPressed: () async {
                                    if (controllerData.text != "") {
                                      //mando la chiamata
                                      String data = controllerData.text;
                                      int quantita = _currentHorizontalIntValue;
                                      print(data + " " + quantita.toString());
                                      Future<SharedPreferences> _prefs =
                                          SharedPreferences.getInstance();
                                      final SharedPreferences prefs =
                                          await _prefs;
                                      String idDispensa =
                                          prefs.getString("idDispensa");
                                      var url =
                                          "https://thispensa.herokuapp.com/inserisciProdottoDispensa";
                                      var params = {
                                        "uid": _auth.currentUser.uid.toString(),
                                        "tokenJWT": await _auth.currentUser
                                            .getIdToken(),
                                        "nome": widget.nomeProdotto,
                                        "idDispensa": idDispensa,
                                        "qta": quantita,
                                        "dataScadenza": data,
                                        "barcode": widget.barcode
                                      };
                                      //? Richiesta post al server node con parametri
                                      http.post(Uri.parse(url),
                                          body: json.encode(params),
                                          headers: {
                                            "Accept": "application/json",
                                            HttpHeaders.contentTypeHeader:
                                                "application/json"
                                          }).then((response) async {
                                        Map data = jsonDecode(response.body);

                                        if (data["errore"])
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                  'Errore nell\'inserimento sul server'),
                                            ),
                                          );
                                        else
                                          widget._callback();

                                        Navigator.of(context).pop();
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                              'Errore nell\'inserimento sul server'),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                            Container(
                              height: 60.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colori.primario,
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: TextButton(
                                  child: Text(
                                    'Annulla',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                  onPressed: () {
                                    //navigation.pop
                                    Navigator.of(context).pop();
                                  }),
                            ),
                          ],
                        ),
                      ),

                      /*Container(
                      child: TextField(
                          controller: controllerQuantita,
                          decoration: new InputDecoration(
                              labelText: "Enter your number"),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ]),
                      padding: EdgeInsets.all(16.0)),*/
                      //Image.network('$urlImmagine', fit: BoxFit.contain),
                    ]),
              ),
            ),
          ),
        ));
  }
}
