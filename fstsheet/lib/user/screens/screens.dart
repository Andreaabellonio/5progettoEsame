//import 'dart:html';

import 'package:flutter/material.dart';
//file puntatori alle schede
import 'package:fstsheet/user/screens/sheets/_Help.dart';
import 'package:fstsheet/user/screens/sheets/_Privacy.dart';
import 'package:fstsheet/user/screens/sheets/_Account.dart';
import 'package:fstsheet/user/screens/sheets/_Info.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

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
        child: policyPrivacy(), //classe recuperabile in: user/screens/sheets/_Privacy.dart
      ),
    );
  }
}

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  HelpState createState() =>
      HelpState(); //classe recuperabile in: user/screens/sheets/_Help.dart
}

class Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Versione"),
      ),
      body: Center(
        child: versionApp(), //classe recuperabile in: user/screens/sheets/_Info.dart
      ),
    );
  }
}

class Themes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assistenza"),
      ),
      body: Center(),
    );
  }
}
