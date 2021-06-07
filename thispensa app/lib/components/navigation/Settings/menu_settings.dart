import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:thispensa/components/login/autenticazione.dart';
import 'package:thispensa/styles/colors.dart';
//import 'user/screens/screens.dart';
import 'button_settings/stgButton.dart';
import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;

class Settings {
  Widget buildButton(String text, IconData icon, Widget action, var context) {
    return Column(
      children: [
        ClipOval(
          child: Material(
            color: Colori.primario, // button color
            child: InkWell(
              splashColor: Colors.red, // inkwell color
              child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Icon(
                    icon,
                    size: 37,
                  )),
              onTap: () {
                (text != "Feedback")
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => action),
                      )
                    : Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => action),
                      );
              },
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Text(text),
      ],
    );
  }

  showMenu(context) {
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
        _auth.signOut().then((value) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => PaginaAutenticazione())));
      });
    }

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
                color: Colori.primario),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 36,
                ),
                SizedBox(
                    height: (415.0),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0), //16
                            topRight: Radius.circular(50.0),
                          ),
                          color: Colors.white,
                        ),
                        child: Stack(
                          alignment: Alignment(0, 0),
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              top: -36,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    border: Border.all(
                                        color: Colori.primario, width: 10)),
                                child: Center(
                                  child: ClipOval(
                                    /*child: Image.asset(
                                      "assets/foodPhoto.png",
                                      fit: BoxFit.contain,
                                    ),*/
                                    child: Image.asset(
                                      "assets/backgroundWhite.png",
                                      fit: BoxFit.contain,
                                      height: 36,
                                      width: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(28.0),
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildButton(
                                                "Account",
                                                Icons.perm_identity,
                                                Account(),
                                                context),
                                            buildButton(
                                                "Invita la famiglia",
                                                Icons.supervisor_account,
                                                Invite(),
                                                context),
                                            buildButton("Privacy", Icons.lock,
                                                Privacy(), context),
                                          ],
                                        ),
                                        SizedBox(height: 28),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildButton(
                                                "Feedback",
                                                Icons.help_outline,
                                                Help(),
                                                context),
                                            buildButton(
                                                "Informazioni",
                                                Icons.info,
                                                InfoState(),
                                                context),
                                            buildButton(
                                                "Tema",
                                                Icons.color_lens,
                                                Themes(),
                                                context),
                                          ],
                                        ),
                                        SizedBox(height: 40),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ClipOval(
                                              child: Material(
                                                color: Colori
                                                    .primario, // button color
                                                child: InkWell(
                                                  splashColor: Colors
                                                      .red, // inkwell color
                                                  child: SizedBox(
                                                      width: 70,
                                                      height: 70,
                                                      child: Icon(
                                                        Icons.save,
                                                        size: 37,
                                                      )),
                                                  onTap: () async {
                                                    EasyLoading.instance
                                                            .indicatorType =
                                                        EasyLoadingIndicatorType
                                                            .foldingCube;
                                                    EasyLoading.instance
                                                            .userInteractions =
                                                        false;
                                                    EasyLoading.show();
                                                    await _signOut();
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                PaginaAutenticazione()));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text("Esci"),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))),
              ],
            ),
          );
        });
  }
}
