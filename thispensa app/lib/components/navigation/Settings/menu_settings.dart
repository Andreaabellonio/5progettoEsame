import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thispensa/styles/colors.dart';
//import 'user/screens/screens.dart';
import 'button_settings/stgButton.dart';
import 'package:http/http.dart' as http;

//import 'style.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
//building buttons
  Widget buildButton(String text, IconData icon, Widget action) {
    return /*Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child:Container(
              width: 18,
          padding:EdgeInsets.symmetric(vertical: 5.0),
          child:*/
        ElevatedButton.icon(
      onPressed: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => action),
        )
      },
      icon: Icon(icon),
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.black,
        primary: Colors.white,
        alignment: Alignment.centerLeft,
      ),
      label: Text(text),
    );
    /*)],
    );*/
  }

//-----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Settings'),
        ),
        body: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //classi in user/screens/screens.dart
            buildButton("Account", Icons.perm_identity, Account()),
            buildButton(
                "Invita la famiglia", Icons.supervisor_account, Invite()),
            buildButton("Privacy", Icons.lock, Privacy()),
            buildButton("Assistenza", Icons.help_outline, Help()),
            buildButton("Informazioni", Icons.info, Info()),
            buildButton("Tema", Icons.color_lens, Themes()),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(
                Icons.save,
                color: Colors.grey[400],
              ),
              label: Text(
                "Esci",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  foreground: paint,
                ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colori.primario)),
              onPressed: () async {
                await _signOut();
              },
            ),
          ],
        )));
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
