import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NumberPicker Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dispensaController = TextEditingController();
  static const TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  Widget home(BuildContext context) {
    return new Material(
      child: new RaisedButton(
        child: const Text('Show Pop-up'),
        color: Theme.of(context).accentColor,
        elevation: 4.0,
        splashColor: Colors.amberAccent,
        textColor: const Color(0xFFFFFFFF),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => _buildAboutDialog(context),
          );
          // Perform some action
        },
      ),
    );
  }

  Widget _buildAboutDialog(BuildContext context) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Center(
          child: new AlertDialog(
            titlePadding: EdgeInsets.symmetric(vertical: 40.0),
            title: const Text(
              'Inserisci la Tua Prima Thispensa',
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
                      keyboardType: TextInputType.name,
                      controller: _dispensaController,
                      decoration: const InputDecoration(
                          labelText: 'Inserisci la tua prima dispensa!'),
                      validator: (String? value) {
                        if (value!.isEmpty)
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
                        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            //tutto tuo in bocca al lupo
                          }
                        },
                        child: Text("Crea la Dispensa",
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutText() {
    return new RichText(
      text: new TextSpan(
        text: 'Inserisci la tua prima Dispensa!\n\n',
        //text: 'Android Popup Menu displays the menu below the anchor text if space is available otherwise above the anchor text. It disappears if you click outside the popup menu.\n\n',
        style: const TextStyle(color: Colors.black87),
        children: <TextSpan>[
          const TextSpan(
              text:
                  'Inizia ad utilizzare la tua applicazione inserendo la tua prima Thispensa e trova tutti i vantaggi nel raggruppare i tuoi prodotti in un unico luogo.\n\n'),
          const TextSpan(
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

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(top: 100.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: new Column(
        children: <Widget>[
          home(context),
        ],
      ),
    );
  }
}
