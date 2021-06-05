import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:thispensa/components/navigation/dispensa/dispensa.dart';
import 'package:thispensa/components/navigation/shopping_list/shoppingList.dart';
import 'package:thispensa/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Settings/menu_settings.dart';

class temaApp {
  static ThemeMode tema;
}

class PaginaVera extends StatefulWidget {
  @override
  _PaginaVeraState createState() => _PaginaVeraState();
}

class _PaginaVeraState extends State<PaginaVera> {
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

  @override
  _MyNavWidgetState createState() => _MyNavWidgetState();
}

class _MyNavWidgetState extends State<MyNavWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      String tema = prefs.getString("tema");
      if (tema != null)
        switch (tema) {
          case "sistema":
            temaApp.tema = ThemeMode.system;
            break;
          case "chiaro":
            temaApp.tema = ThemeMode.light;
            break;
          case "scuro":
            temaApp.tema = ThemeMode.dark;
            break;
        }
      else
        temaApp.tema = ThemeMode.system;

      EasyLoading.dismiss();
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    Container(
      child: MyDispensa(),
    ),
    Container(
      child: MyListWidget(),
    ),
  ];

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Widget buildPageView() {
    return PageView(
        controller: pageController,
        onPageChanged: (index) {
          pageChanged(index);
        },
        children: _widgetOptions);
  }

  void pageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    if (index == 2) {
      Settings().showMenu(context);
    } else {
      setState(() {
        _selectedIndex = index;
        pageController.animateToPage(index,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: buildPageView(),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.food_bank),
                label: 'Dispensa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.ballot),
                label: 'Lista',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Impostazioni',
              ),
            ],
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.black,
            onTap: (index) {
              bottomTapped(index);
            },
          ),
        ));
  }
}
