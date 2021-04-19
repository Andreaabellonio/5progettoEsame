import 'package:flutter/material.dart';
import 'colors.dart';
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
        primaryColor: Colori.primario,
      ),
      home: MyHomePage(title: 'ThisPensa'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //style univoco per le label
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final emailController = TextEditingController();
  final pwdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //creazione lbl mail
    final lblMail = TextField(
      style: style, //richiamo style univoco
      controller: emailController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final lblPassword = TextField(
      obscureText: true,
      style: style,
      controller: pwdController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );


    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colori.primario,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        onPressed: () {
          //ENRICO passi i valori di pwd ed email
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  content: Text(emailController.text +
                      pwdController.text)); // per recupero dati
            },
          );
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );

    final registerButton= Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colori.primario,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        onPressed: () {
          //ENRICO passi i valori di pwd ed email
          
        },
        child: Text("Register",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      backgroundColor: Colori.sfondo,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(height: 75.0),
                      //creazione degli scomparti
                      SizedBox(
                        height: 155.0,
                        child: Image.asset(
                          "assets/foodPhoto.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 45.0),
                      lblMail, //oggettistica email
                      SizedBox(height: 25.0),
                      lblPassword, //oggettistica pwd
                      SizedBox(
                        height: 50.0,
                      ),
                      loginButton,
                      SizedBox(
                        height: 15.0,
                      ),
                      registerButton,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
