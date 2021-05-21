import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:Thispensa/components/navigation/dispensa/dispensa.dart';
import 'package:Thispensa/components/navigation/shopping_list/shoppingList.dart';
import 'package:Thispensa/styles/colors.dart';
import 'Settings/menu_settings.dart';

class PaginaVera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thispensa',
      theme: ThemeData(
        primaryColor: Colori.primario,
      ),
      home: MyNavWidget(),
      builder: EasyLoading.init(),
    );
  }
}

class MyNavWidget extends StatefulWidget {
  MyNavWidget({Key key}) : super(key: key);

  //MyNavWidget({Key key}) : super(key: key);

  @override
  _MyNavWidgetState createState() => _MyNavWidgetState();
}

class _MyNavWidgetState extends State<MyNavWidget> {
  MyDispensa obj;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EasyLoading.dismiss();
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    /*Container(
      child: UserPage(),
      ),*/

    Container(
      //child: MyDispensa(),
      //child: this.idDispensa != null ? obj.idDispensa : null,
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

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          /*appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Thispensa'),
          ),*/
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
