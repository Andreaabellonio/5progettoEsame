import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'user/screens/screens.dart';
//import 'package:image_picker/image_picker.dart';

//import 'style.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserPage(),
    );
  }
}


class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);
  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
///-------------------------------------------------------
//building buttons
  Widget buildButton(String text, IconData icon, Widget action) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => action),
              )},
            icon: Icon(icon),
            style: ElevatedButton.styleFrom(
              onPrimary: Colors.black,
              primary: Colors.white,
            ),
            label: Text(text),
          ),
        ),
      ],
    );
  }

//-----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("user"), //widget.title
        ),
        body: Container(
            child: Column(
          children: <Widget>[
            //classi in user/screens/screens.dart
            buildButton("Account", Icons.perm_identity, Account()),
            buildButton("Invita la famiglia", Icons.supervisor_account, Invite()),
            buildButton("Privacy", Icons.lock, Privacy()),
            buildButton("Assistenza", Icons.help_outline, Help()),
            buildButton("Informazioni", Icons.info, Info()),
            buildButton("Tema", Icons.color_lens, Themes()),
          ],
        )));
  }
}



