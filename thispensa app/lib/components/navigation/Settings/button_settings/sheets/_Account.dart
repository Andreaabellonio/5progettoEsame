import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:thispensa/components/login/autenticazione.dart';
import '../../../../../styles/colors.dart';
//import 'package:flutter_image_ppicker/home_screen.dart';
//file puntatori al'origine'
import '../stgButton.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AccountState extends State<Account> {
  TextEditingController _nameController;
  TextEditingController _surnameController;
  TextEditingController _passwordOldController;
  TextEditingController _passwordChkController;
  TextEditingController _passwordNewController;
  bool _success;
  String _err = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
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
      });
    });
    super.initState();
  }

//funzione per la creazione delle textbox
  Widget textBoxController(String text, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(8.0), //padding da tutti i lati di 8
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Account'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
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
                textBoxController("Nome", _nameController),
                textBoxController("Cognome", _surnameController),
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
                          if (_nameController.text != "" &&
                              _surnameController.text != "") {
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
                                  _success = true;
                                }
                              });
                            } catch (err) {
                              setState(() {
                                _err = err.message;
                                _success = false;
                              });
                            }
                          } else {
                            setState(() {
                              _err = "Inserire un nome e una password!";
                              _success = false;
                            });
                          }
                        },
                      ),
                      TextField(
                        controller: _passwordOldController,
                        decoration: const InputDecoration(
                            labelText: 'Vecchia password'),
                        obscureText: true,
                      ),
                      TextField(
                        controller: _passwordNewController,
                        decoration:
                            const InputDecoration(labelText: 'Nuova password'),
                        obscureText: true,
                      ),
                      TextField(
                        controller: _passwordChkController,
                        decoration: const InputDecoration(
                            labelText: 'Conferma password'),
                        obscureText: true,
                      ),
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
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colori.primario)),
                        onPressed: () async {
                          final User user =
                              (await _auth.signInWithEmailAndPassword(
                            email: _auth.currentUser.email,
                            password: _passwordOldController.text,
                          ))
                                  .user;
                          if (user.emailVerified) {
                            if (_passwordNewController.text ==
                                _passwordChkController.text) {
                              await _auth.currentUser
                                  .updatePassword(_passwordNewController.text);
                              await _signOut();
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PaginaAutenticazione()));
                            } else {
                              _success = false;
                              _err = "Le password devono corrispondere!";
                            }
                          }
                        },
                      ),
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
                                        'L\'eliminazione include solamente il tuo account e le tue dispense.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
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
                                              await _auth.signOut();
                                            });
                                            await _auth.currentUser.delete();
                                          } catch (e) {
                                            print(e);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Accesso con google fallito: $e'),
                                              ),
                                            );
                                          }
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text('Account eliminato'),
                                          ));
                                          await _signOut();
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyHomePage()));
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
    http.post(Uri.https('thispensa.herokuapp.com', '/logout'), headers: {
      "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/json"
    }).then((response) async {
      await _auth.signOut();
    });
  }
}
