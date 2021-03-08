import 'package:flutter/material.dart';
import './screens/home/home.dart';
import './screens/dispensa/dispensa.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const String _title = 'Thispensa';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    pageHome(),
    pageDispensa()
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
        backgroundColor: Color.fromARGB(255, 55, 149, 82),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color.fromARGB(255, 55, 149, 82),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: 'Dispensa',
            backgroundColor: Color.fromARGB(255, 55, 149, 82),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analisi',
            backgroundColor: Color.fromARGB(255, 55, 149, 82),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ballot),
            label: 'Lista della spesa',
            backgroundColor: Color.fromARGB(255, 55, 149, 82),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Utente',
            backgroundColor: Color.fromARGB(255, 55, 149, 82),
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}