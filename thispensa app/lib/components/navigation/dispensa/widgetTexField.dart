import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thispensa/components/navigation/dispensa/dispensa.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class TextFieldLongPress extends StatefulWidget {
  final String nome;
  final String idDispensa;
  const TextFieldLongPress({Key key, this.nome, this.idDispensa})
      : super(key: key);

  @override
  _TextFieldLongPressState createState() => _TextFieldLongPressState();
}

class _TextFieldLongPressState extends State<TextFieldLongPress> {
  TextEditingController text = TextEditingController();

  FocusNode focus;

  @override
  void initState() {
    focus = FocusNode();
    text.text = widget.nome;
    super.initState();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    focus.addListener(() {
      if (focus.hasFocus) {
      } else {}
    });
    return SizedBox(
        width: MediaQuery.of(context).size.width - 200,
        child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Container(
                  height: 40,
                  child: TextFormField(
                    focusNode: focus,
                    enabled: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    controller: text,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    onFieldSubmitted: (value) {
                      print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
                      aggiornaNomeDispensa(text.text);
                    },
                  ),
                ),
                Container(
                  height: 40,
                  color: Colors.transparent,
                  child: GestureDetector(
                    onLongPress: () {
                      focus.requestFocus();
                    },
                    onTap: () {
                      focus.unfocus();
                    },
                  ),
                ),
              ],
            )));
  }

  Future<void> aggiornaNomeDispensa(String nome) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var params = {
      "nomeDispensa": nome,
      "idDispensa": widget.idDispensa,
      "uid": _auth.currentUser.uid.toString(),
      "tokenJWT": await _auth.currentUser.getIdToken(),
    };
    http.Response res = await http.post(
        Uri.https('thispensa.herokuapp.com', '/aggiornaDispensa'),
        body: json.encode(params),
        headers: {
          "Accept": "application/json",
          HttpHeaders.contentTypeHeader: "application/json"
        });
    if (res.statusCode == 200) {
      Map data = jsonDecode(res.body);
      if (!data["errore"]) {
        prefs.setString("nomeDispensa", nome);
        MyDispensaState().onRefresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nome aggiornato con successo!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Errore durante l'aggiornamento!"),
          ),
        );
      }
    } else {
      throw "Unable change pantry nome.";
    }
  }
}
