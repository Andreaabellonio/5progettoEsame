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

  @override
  _MyNavWidgetState createState() => _MyNavWidgetState();
}

class _MyNavWidgetState extends State<MyNavWidget> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    Container(
      child: SettingsPage(),
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
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
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
                icon: Icon(Icons.account_circle),
                label: 'Settings',
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
