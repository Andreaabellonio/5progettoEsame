import 'package:thispensa/components/navigation/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'dart:io' show Platform;

import 'sheets/_Help.dart';
import 'sheets/_Privacy.dart';
import 'sheets/_Account.dart';

class Account extends StatefulWidget {
  const Account({Key key}) : super(key: key);

  @override
  AccountState createState() =>
      AccountState(); //classe recuperabile in: user/screens/sheets/_Account.dart
}

class Invite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invite"),
      ),
      body: Center(),
    );
  }
}

class Privacy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy"),
      ),
      body: Center(
        child:
            policyPrivacy(), //classe recuperabile in: user/screens/sheets/_Privacy.dart
      ),
    );
  }
}

class Help extends StatefulWidget {
  const Help({Key key}) : super(key: key);

  @override
  HelpState createState() =>
      HelpState(); //classe recuperabile in: user/screens/sheets/_Help.dart
}

class InfoState extends StatelessWidget {
  String version2 = Platform.version;

  Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "About",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
              ),
              Divider(),
            ],
          ),
          // The version tile :
          ListTile(
            enabled: false,
            title: Text("Version"),
            trailing: FutureBuilder(
              future: getVersionNumber(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
                  Container(
                padding: EdgeInsets.symmetric(
                  vertical: 250.0,
                ),
                child: Column(children: [
                  Icon(
                    Icons.developer_board,
                    size: 100,
                  ),
                  Text(
                    "vv. " + snapshot.data,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(version2),
                ]),
              ), /*Text(
                snapshot.hasData ? snapshot.data : "Loading ...",
                style: TextStyle(color: Colors.black38),
              ),*/
            ),
          ),
          // ...
        ],
      ),
    );
  }

  /*Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }*/
}
/*
class InfoState extends StatelessWidget {
  @override
  Widget build(context) {
    FutureBuilder(
    future: getVersionNumber(), // The async function we wrote earlier that will be providing the data i.e vers. no
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>	Text(snapshot.hasData ? snapshot.data : "Loading ...",) // The widget using the data
  ),
  }
}*/

class Themes extends StatefulWidget {
  @override
  _ThemesState createState() => _ThemesState();
}

class _ThemesState extends State<Themes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tema"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Tema di sistema'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: temaApp.tema,
                onChanged: (ThemeMode value) async {
                  Future<SharedPreferences> _prefs =
                      SharedPreferences.getInstance();
                  final SharedPreferences prefs = await _prefs;
                  prefs.setString("tema", "sistema");
                  setState(() {
                    temaApp.tema = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Tema chiaro'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: temaApp.tema,
                onChanged: (ThemeMode value) async {
                  Future<SharedPreferences> _prefs =
                      SharedPreferences.getInstance();
                  final SharedPreferences prefs = await _prefs;
                  prefs.setString("tema", "chiaro");
                  setState(() {
                    temaApp.tema = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Tema scuro'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: temaApp.tema,
                onChanged: (ThemeMode value) async {
                  Future<SharedPreferences> _prefs =
                      SharedPreferences.getInstance();
                  final SharedPreferences prefs = await _prefs;
                  prefs.setString("tema", "scuro");
                  setState(() {
                    temaApp.tema = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
