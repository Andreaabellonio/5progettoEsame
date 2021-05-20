import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thispensa/components/login/autenticazione.dart';
import '../../../../../styles/colors.dart';
//import 'package:flutter_image_ppicker/home_screen.dart';
//file puntatori al'origine'
import '../stgButton.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AccountState extends State<Account> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _passwordOldController = TextEditingController();
  TextEditingController _passwordChkController = TextEditingController();
  TextEditingController _passwordNewController = TextEditingController();
  bool _success;
  String _err = "";
  bool googleLogin = true;

  @override
  void initState() {
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.foldingCube;
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show();
    Future.delayed(Duration.zero, () async {
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      googleLogin = prefs.getBool("googleLogin");
      var params = {
        "uid": _auth.currentUser.uid.toString(),
        "tokenJWT": await _auth.currentUser.getIdToken()
      };
      http.post(Uri.https('thispensa.herokuapp.com', '/leggiUtente'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            "withCredential": "true",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Map data = jsonDecode(response.body);
        if (!data["errore"]) {
          setState(() {
            _nameController = TextEditingController(
              text: data["data"]["nome"],
            );
            _surnameController = TextEditingController(
              text: data["data"]["cognome"],
            );
          });
        }
        EasyLoading.dismiss();
      });
    });
    super.initState();
  }

//funzione per la creazione delle textbox
  Widget textBoxController(String text, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(1.0), //padding da tutti i lati di 8
      child: TextField(
        controller: controller, //testo all'interno della textbox
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Colors.grey,
            height: 0.5,
          ),
          //contorno attorno alla textbox
          //border: OutlineInputBorder(), //arrotondamento degli angoli
          labelText: text, //miniatura della scritta
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
    final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
    return Scaffold(
        appBar: AppBar(
          title: Text('Account'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                /*new Container(
                height: 80.0,
                width: 80.0,
                child: new Image.asset('/assets/images/cactus.jpg'),
                decoration: new BoxDecoration(
                    color: const Color(0xff7c94b6),
                    borderRadius: BorderRadius.all(const Radius.circular(50.0)),
                    border: Border.all(color: const Color(0xFF28324E)),
                ),

                ),*/

                //CREAZIONE DELLE DUE TEXTBOX
                Form(
                    key: _formKey1,
                    child: Column(
                      children: [
                        Text("Modifica dati account"),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Inserisci un nome per continuare';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _surnameController,
                          decoration:
                              const InputDecoration(labelText: 'Cognome'),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'Inserisci un cognome per continuare';
                            }
                            return null;
                          },
                        ),
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: _auth.currentUser.email,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                //textBoxController("E-Mail", _emailController),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.save,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          "Salva dati",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            foreground: paint,
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colori.primario)),
                        onPressed: () async {
                          if (_formKey1.currentState.validate()) {
                            if (_nameController.text != "" &&
                                _surnameController.text != "") {
                              EasyLoading.instance.indicatorType =
                                  EasyLoadingIndicatorType.foldingCube;
                              EasyLoading.instance.userInteractions = false;
                              EasyLoading.show();
                              try {
                                var params = {
                                  "uid": _auth.currentUser.uid.toString(),
                                  "tokenJWT":
                                      await _auth.currentUser.getIdToken(),
                                  "nome": _nameController.text,
                                  "cognome": _surnameController.text
                                };
                                http.post(
                                    Uri.https('thispensa.herokuapp.com',
                                        '/aggiornaUtente'),
                                    body: json.encode(params),
                                    headers: {
                                      "Accept": "application/json",
                                      HttpHeaders.contentTypeHeader:
                                          "application/json"
                                    }).then((response) async {
                                  Map data = jsonDecode(response.body);
                                  if (!data["errore"]) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Aggiornamento dei dati avvenuto con successo"),
                                      ),
                                    );
                                  }
                                  EasyLoading.dismiss();
                                });
                              } catch (err) {
                                EasyLoading.dismiss();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Errore"),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Inserire un nome e una password!"),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      (!googleLogin) ? SizedBox(height: 30) : SizedBox.shrink(),
                      (!googleLogin)
                          ? Divider(
                              thickness: 4,
                              color: Colors.grey,
                            )
                          : SizedBox.shrink(),
                      (!googleLogin)
                          ? Form(
                              key: _formKey2,
                              child: Column(
                                children: [
                                  Text("Modifica password"),
                                  TextFormField(
                                    controller: _passwordOldController,
                                    decoration: const InputDecoration(
                                        labelText: 'Vecchia password'),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Inserisci una password per continuare';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                  ),
                                  TextFormField(
                                    controller: _passwordNewController,
                                    decoration: const InputDecoration(
                                        labelText: 'Nuova password'),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Inserisci una password per continuare';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                  ),
                                  TextFormField(
                                    controller: _passwordChkController,
                                    decoration: const InputDecoration(
                                        labelText: 'Conferma password'),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Inserisci una password per continuare';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Icon(
                                          Icons.lock,
                                          color: Colors.grey[400],
                                        ),
                                        label: Text(
                                          "Cambia password",
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontStyle: FontStyle.normal,
                                            foreground: paint,
                                          ),
                                        ),
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colori.primario)),
                                        onPressed: () async {
                                          if (_formKey2.currentState
                                              .validate()) {
                                            final User user = (await _auth
                                                    .signInWithEmailAndPassword(
                                              email: _auth.currentUser.email,
                                              password:
                                                  _passwordOldController.text,
                                            ))
                                                .user;
                                            if (user.emailVerified) {
                                              if (_passwordNewController.text ==
                                                  _passwordChkController.text) {
                                                if (_passwordOldController
                                                        .text !=
                                                    _passwordNewController
                                                        .text) {
                                                  EasyLoading.instance
                                                          .indicatorType =
                                                      EasyLoadingIndicatorType
                                                          .foldingCube;
                                                  EasyLoading.instance
                                                      .userInteractions = false;
                                                  EasyLoading.show();
                                                  await _auth.currentUser
                                                      .updatePassword(
                                                          _passwordNewController
                                                              .text);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Password aggiornata, rieffettuare l'accesso"),
                                                    ),
                                                  );
                                                  await _signOut();
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PaginaAutenticazione()));
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "La nuova password deve essere differente da quella precedente"),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      "Le password devono corrispondere!"),
                                                ));
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Problema di accesso relativo all'acccount."),
                                              ));
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ))
                          : SizedBox.shrink(),
                      Divider(
                        thickness: 4,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 40),
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          "Elimina account",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            foreground: paint,
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colori.primario)),
                        onPressed: () async {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text(
                                        'Sei sicuro di voler eliminare DEFINITIVAMENTE l\'account?'),
                                    content: const Text(
                                        'L\'eliminazione include il tuo account, le dispense e le liste della spesa create da te.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Annulla'),
                                        child: const Text('Annulla'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          EasyLoading.instance.indicatorType =
                                              EasyLoadingIndicatorType
                                                  .foldingCube;
                                          EasyLoading.instance
                                              .userInteractions = false;
                                          EasyLoading.show();
                                          try {
                                            var params = {
                                              "uid": _auth.currentUser.uid
                                                  .toString(),
                                              "tokenJWT": await _auth
                                                  .currentUser
                                                  .getIdToken(),
                                            };
                                            http.post(
                                                Uri.https(
                                                    'thispensa.herokuapp.com',
                                                    '/eliminaAccount'),
                                                body: json.encode(params),
                                                headers: {
                                                  "Accept": "application/json",
                                                  HttpHeaders.contentTypeHeader:
                                                      "application/json"
                                                }).then((response) async {
                                              await _auth.currentUser.delete();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Account eliminato con successo"),
                                                ),
                                              );                                              
                                              await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MyHomePage()));
                                            });
                                          } catch (e) {
                                            print(e);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Errore nell\'eliminazione dell\'account $e'),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('SI'),
                                      ),
                                    ],
                                  ));
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(_success == null
                      ? ''
                      : (_success
                          ? 'Aggiornamento dei dati avvenuto con successo!'
                          : _err)),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> _signOut() async {
    var params = {
      "uid": _auth.currentUser.uid.toString(),
      "tokenJWT": await _auth.currentUser.getIdToken()
    };
    http.post(Uri.https('thispensa.herokuapp.com', '/logout'),
        body: json.encode(params),
        headers: {
          "Accept": "application/json",
          HttpHeaders.contentTypeHeader: "application/json"
        }).then((response) async {
      await _auth.signOut();
    });
  }
}
