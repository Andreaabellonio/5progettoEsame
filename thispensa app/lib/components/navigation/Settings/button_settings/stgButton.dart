import 'package:thispensa/components/navigation/Settings/button_settings/sheets/_Feedback.dart';
import 'package:thispensa/components/navigation/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sheets/_Info.dart';
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
  FeedbackWidget createState() => FeedbackWidget();
}

class Info extends StatefulWidget {
  Info({Key key}) : super(key: key);

  @override
  InfoState createState() => InfoState();
}

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
