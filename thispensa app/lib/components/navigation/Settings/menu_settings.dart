import 'package:flutter/material.dart';
//import 'user/screens/screens.dart';
import 'button_settings/stgButton.dart';

//import 'style.dart';

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
          ],
        )));
  }
}
