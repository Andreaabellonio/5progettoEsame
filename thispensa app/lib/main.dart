import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'components/login/autenticazione.dart';
import 'components/navigation/navigation_bar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (_auth.currentUser != null && _auth.currentUser.emailVerified) {
    try {
      var params = {
        "uid": _auth.currentUser.uid.toString(),
        "tokenJWT": await _auth.currentUser.getIdToken()
      };
      http.post(Uri.https('thispensa.herokuapp.com', '/login'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            "withCredential": "true",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Map data = jsonDecode(response.body);
        if (!data["errore"]) {
          inviaTokenFCM();
          runApp(PaginaVera());
        } else {
          runApp(PaginaAutenticazione());
        }
      });
    } catch (ex) {
      print(ex);
    }
  } else {
    runApp(PaginaAutenticazione());
  }
}

Future<void> inviaTokenFCM() async {
  if (_auth.currentUser != null) {
    String token = await FirebaseMessaging.instance.getToken();
    var params = {
      "uid": _auth.currentUser.uid.toString(),
      "token": token,
      "tokenJWT": await _auth.currentUser.getIdToken()
    };
    http.post(Uri.https('thispensa.herokuapp.com', '/aggiornaTokenFCM'),
        body: json.encode(params),
        headers: {
          "Accept": "application/json",
          "withCredential": "true",
          HttpHeaders.contentTypeHeader: "application/json"
        });
  }
}
