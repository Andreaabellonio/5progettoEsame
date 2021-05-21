import 'dart:convert';
import 'dart:io';
import '../style/colors.dart';
import '../nav/nav.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../login/login.dart';

/*final FirebaseAuth auth = FirebaseAuth.instance;
class UserPage extends StatefulWidget {
  UserPage({this.auth});
  final FirebaseAuth auth;
  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  _UserPage({this.auth});
  final FirebaseAuth auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("USER PAGE"),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: () async {
                print("UE");
                print(auth.currentUser);
                final User user = auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Nessuno loggato'),
                  ));
                  return;
                }
                await _signOut();
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
/*
                final String uid = user.uid;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('logout avvenuto con successo'),
                ));
                */
              },
              icon: Icon(Icons.logout),
            );
          })
        ],
      ),
      body: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.all(50),
          child: Text(auth.currentUser.email),
        ),
        TextButton(
            child: Text("Resetta password"),
            onPressed: () async {
              await auth.sendPasswordResetEmail(
                  email: auth.currentUser.email);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Email per resettare la password inviata'),
              ));
              await _signOut();
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            }),
        TextButton(
            child: Text("Elimina account"),
            onPressed: () async {
              try {
                await auth.currentUser.delete();
              } catch (e) {
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Accesso con google fallito: $e'),
                  ),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Account eliminato'),
              ));
              await _signOut();
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            })
      ]),
    );
  }

  Future<void> _signOut() async {
    http.post(Uri.http('192.168.137.1:23377', '/login'), headers: {
      "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/json"
    }).then((response) async {
      Map data = jsonDecode(response.body);
      if (!data["errore"])
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyNavWidget()),
          (route) => false,
        );
    });
    await auth.signOut();
  }
}*/