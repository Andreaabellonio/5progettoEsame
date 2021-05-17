import 'package:flutter/material.dart';
import 'package:thispensa/list/list.dart';
import '../utente/utente.dart';
import '../dispensa/dispensa.dart';
import '../home/home.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;


class MyNavWidget extends StatefulWidget {
  MyNavWidget({this.auth});
  final FirebaseAuth auth;
  //MyNavWidget({Key key}) : super(key: key);

  @override
  _MyNavWidgetState createState() => _MyNavWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyNavWidgetState extends State<MyNavWidget> {
  _MyNavWidgetState({this.auth});
  final FirebaseAuth auth;

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    /*Container(
      child: UserPage(),
      ),*/
    Container(
      child: MyDispensa(),
      ),
    /*Text(
      'Index 2: School',
      style: optionStyle,
    ),*/
    Container(
      child: MyListWidget(),
      ),
    Container(
      child: SettingsPage(),
      ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thispensa'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          /*BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Dispensa',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analisi',
          ),*/
          BottomNavigationBarItem(
            icon: Icon(Icons.ballot),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Utente',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
