import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:Thispensa/styles/colors.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PopUpClass {
  Function callback;
  bool first = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dispensaController = TextEditingController();
  TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );
  FocusNode yourFocus = FocusNode();

  Widget popupDispensa(BuildContext context) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      EasyLoading.dismiss();
    });
    return WillPopScope(
      onWillPop: () async => !first,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              /*padding: EdgeInsets.only(
                  top: yourFocus.hasFocus
                      ? MediaQuery.of(context).size.height / 2 -
                          420 // adjust values according to your need
                      : MediaQuery.of(context).size.height -
                          MediaQuery.of(context).size.height +
                          30), //? 01:26 22/05/2021*/
              child: Center(
                child: new AlertDialog(
                  titlePadding: EdgeInsets.symmetric(vertical: 40.0),
                  title: Text(
                    (first)
                        ? 'Inserisci la tua prima Thispensa!'
                        : 'Inserisci una nuova Thispensa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0))),
                  content: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: new Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        //SizedBox(height: 60),
                        _buildAboutText(),
                        _buildLogoAttribution(),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    Form(
                      key: _formKey, //?

                      child: Column(
                        children: [
                          TextFormField(
                            focusNode: yourFocus,
                            keyboardType: TextInputType.name,
                            controller: _dispensaController,
                            decoration: InputDecoration(
                                labelText: (first)
                                    ? 'Inserisci la tua prima dispensa!'
                                    : 'Inserisci una nuova dispensa!'),
                            validator: (String value) {
                              if (value.isEmpty)
                                return 'Inserire un nome per continuare <es. \'Dispensa Casa\' >';
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(30.0),
                              color: Color.fromARGB(255, 249, 193, 108),
                              child: MaterialButton(
                                minWidth: MediaQuery.of(context).size.width,
                                padding:
                                    EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    EasyLoading.instance.indicatorType =
                                        EasyLoadingIndicatorType.foldingCube;
                                    EasyLoading.instance.userInteractions =
                                        false;
                                    EasyLoading.show();
                                    var params = {
                                      "uid": _auth.currentUser.uid.toString(),
                                      "tokenJWT":
                                          await _auth.currentUser.getIdToken(),
                                      "nomeDispensa": _dispensaController.text
                                    };
                                    http.post(
                                        Uri.https('thispensa.herokuapp.com',
                                            '/creaDispensa'),
                                        body: json.encode(params),
                                        headers: {
                                          "Accept": "application/json",
                                          "withCredential": "true",
                                          HttpHeaders.contentTypeHeader:
                                              "application/json"
                                        }).then((response) async {
                                      _dispensaController.text = "";
                                      Map data = jsonDecode(response.body);
                                      if (!data["errore"]) {
                                        Future<SharedPreferences> _prefs =
                                            SharedPreferences.getInstance();
                                        final SharedPreferences prefs =
                                            await _prefs;
                                        prefs.setString(
                                            "idDispensa", data["idDispensa"]);
                                        prefs.setString(
                                            "idDispensa", data["nome"]);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Dispensa aggiunta con successo!'),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text('Errore nel server!'),
                                          ),
                                        );
                                      }
                                      await callback();
                                      EasyLoading.dismiss();
                                      Navigator.of(context).pop();
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            'Inserire un nome per continuare!'),
                                      ),
                                    );
                                  }
                                },
                                child: Text("Crea la Dispensa",
                                    textAlign: TextAlign.center),
                              )),
                          SizedBox(height: 10),
                          (!first)
                              ? Material(
                                  elevation: 5.0,
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Colori.grigioTenue,
                                  child: MaterialButton(
                                    minWidth: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 10.0),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Annulla",
                                        textAlign: TextAlign.center),
                                  ),
                                )
                              : SizedBox.shrink(),
                          /*SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          ),*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutText() {
    return new RichText(
      text: new TextSpan(
        text: (first)
            ? 'Inserisci la tua prima Dispensa!\n\n'
            : 'Inserisci una nuova Dispensa!\n\n',
        //text: 'Android Popup Menu displays the menu below the anchor text if space is available otherwise above the anchor text. It disappears if you click outside the popup menu.\n\n',
        style: const TextStyle(color: Colors.black87),
        children: <TextSpan>[
          TextSpan(
              text:
                  'Inizia ad utilizzare la tua applicazione inserendo la tua prima una nuova Thispensa e trova tutti i vantaggi nel raggruppare i tuoi prodotti in un unico luogo.\n\n'),
          TextSpan(
            text:
                'All\'interno troverai tantissime funzionalità comode per salvare, cambiare ed eliminare i tuoi prodotti',
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  Widget _buildLogoAttribution() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: new Image.asset(
              "assets/foodPhoto.png",
              width: 32.0,
            ),
          ),
          const Expanded(
            child: const Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: const Text(
                'L\'applicazione ti permetterà di accedere a tutte le funzionalità in maniera totalmente gratuita',
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}