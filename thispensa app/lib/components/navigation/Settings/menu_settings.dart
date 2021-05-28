import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:Thispensa/components/login/autenticazione.dart';
import 'package:Thispensa/styles/colors.dart';
//import 'user/screens/screens.dart';
import 'button_settings/stgButton.dart';
import 'package:http/http.dart' as http;

class Settings {
  Widget buildButton(String text, IconData icon) {
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
              onTap: () {},
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
                                                "Account", Icons.perm_identity),
                                            buildButton("Invita la famiglia",
                                                Icons.supervisor_account),
                                            buildButton("Privacy", Icons.lock),
                                          ],
                                        ),
                                        SizedBox(height: 28),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildButton("Assistenza",
                                                Icons.help_outline),
                                            buildButton(
                                                "Informazioni", Icons.info),
                                            buildButton(
                                                "Tema", Icons.color_lens),
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
                                                    /*EasyLoading.instance.indicatorType =
                                                      EasyLoadingIndicatorType.foldingCube;
                                                  EasyLoading.instance.userInteractions = false;
                                                  EasyLoading.show();
                                                  await _signOut();
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (BuildContext context) =>
                                                              PaginaAutenticazione()));*/
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

//import 'style.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);
  @override
  SettingsStatePage createState() => SettingsStatePage();
}

class SettingsStatePage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Color(0xff344955),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              color: Colori.primario),
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          height: 56.0,
          child: Row(children: <Widget>[
            IconButton(
              onPressed: showMenu,
              icon: Icon(Icons.menu),
              color: Colors.white,
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.add),
              color: Colors.white,
            )
          ]),
        ),
      ),
    );
  }

  Widget buildButton(String text, IconData icon) {
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
              onTap: () {},
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

  showMenu() {
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
                                                "Account", Icons.perm_identity),
                                            buildButton("Invita la famiglia",
                                                Icons.supervisor_account),
                                            buildButton("Privacy", Icons.lock),
                                          ],
                                        ),
                                        SizedBox(height: 28),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildButton("Assistenza",
                                                Icons.help_outline),
                                            buildButton(
                                                "Informazioni", Icons.info),
                                            buildButton(
                                                "Tema", Icons.color_lens),
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
                                                    /*EasyLoading.instance.indicatorType =
                                                      EasyLoadingIndicatorType.foldingCube;
                                                  EasyLoading.instance.userInteractions = false;
                                                  EasyLoading.show();
                                                  await _signOut();
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (BuildContext context) =>
                                                              PaginaAutenticazione()));*/
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
                /*Container(
                  height: 56,
                  color: Colori.primario,
                )*/
              ],
            ),
          );
        });
  }
  /*
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
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => action),
        );
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
                EasyLoading.instance.indicatorType =
                    EasyLoadingIndicatorType.foldingCube;
                EasyLoading.instance.userInteractions = false;
                EasyLoading.show();
                await _signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            PaginaAutenticazione()));
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
      _auth.signOut().then((value) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => PaginaAutenticazione())));
    });
  }*/
}
