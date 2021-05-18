import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thispensa/components/navigation/dispensa/dispensa.dart';
import 'package:thispensa/components/navigation/shopping_list/shoppingList.dart';
import 'Settings/menu_settings.dart';

class MyNavWidget extends StatefulWidget {
  MyNavWidget({this.auth});
  final FirebaseAuth auth;
  //MyNavWidget({Key key}) : super(key: key);

  @override
  _MyNavWidgetState createState() => _MyNavWidgetState();
}

class _MyNavWidgetState extends State<MyNavWidget> {
  _MyNavWidgetState({this.auth});
  final FirebaseAuth auth;

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    /*Container(
      child: UserPage(),
      ),*/

    Container(
      child: MyDispensa(),
    ),
    Container(
      child: MyListWidget(),
    ),
    /*Container(
      child: MyListWidget(),
    ),*/
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
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Thispensa'),
          ),
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              /*BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Utente',
          ),*/
              BottomNavigationBarItem(
                icon: Icon(Icons.food_bank),
                label: 'Dispensa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.ballot),
                label: 'Lista',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.black,
            onTap: _onItemTapped,
          ),
        ));
  }
}
