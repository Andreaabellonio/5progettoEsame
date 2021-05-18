import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../navigation/navigation_bar.dart';
import '../../styles/colors.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PaginaAutenticazione extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thispensa',
      theme: ThemeData(
        primaryColor: Colori.primario,
      ),
      home: MyHomePage(title: 'Thispensa'),
      builder: EasyLoading.init(),
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
  @override
  void initState() {
    if (_auth.currentUser != null) if (_auth.currentUser.emailVerified) {
      var params = {
        "uid": _auth.currentUser.uid.toString(),
        "tokenJWT": _auth.currentUser.getIdToken().toString()
      };
      http.post(Uri.https('thispensa.herokuapp.com', '/login'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            "withCredential": "true",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Map data = jsonDecode(response.body);
        if (!data["errore"]) {
          inviaTokenFCM();
          Future.microtask(() => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MyNavWidget())));
        }
      });
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text("Thispensa"),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/foodPhoto.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 30),
                    _EmailPasswordForm(),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

Future<void> inviaTokenFCM() async {
  String token = await FirebaseMessaging.instance.getToken();
  var params = {"uid": _auth.currentUser.uid.toString(), "token": token};
  http.post(Uri.https('thispensa.herokuapp.com', '/aggiornaTokenFCM'),
      body: json.encode(params),
      headers: {
        "Accept": "application/json",
        "withCredential": "true",
        HttpHeaders.contentTypeHeader: "application/json"
      });
}

class RegisterPage extends StatefulWidget {
  @override
  _registerPage createState() => _registerPage();
}

class _registerPage extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confermaPasswordController =
      TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();

  bool _success;
  String _userEmail = '';
  String _err = "";

  Widget build(BuildContext context) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text("Registrazione"),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/foodPhoto.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 60.0),
                    Form(
                      key: _formKey,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Inserisci una mail per continuare';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Inserisci una password per continuare';
                                  }
                                  return null;
                                },
                                obscureText: true,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                controller: _confermaPasswordController,
                                decoration: const InputDecoration(
                                    labelText: 'Conferma password'),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Inserisci una password per continuare';
                                  }
                                  return null;
                                },
                                obscureText: true,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: _nomeController,
                                decoration:
                                    const InputDecoration(labelText: 'Nome'),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Inserisci un nome per continuare';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: _cognomeController,
                                decoration:
                                    const InputDecoration(labelText: 'Cognome'),
                                validator: (String value) {
                                  if (value.isEmpty) {
                                    return 'Inserisci un cognome per continuare';
                                  }
                                  return null;
                                },
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.person_add,
                                        color: Colors.grey[400],
                                      ),
                                      label: Text(
                                        "Registrati",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontStyle: FontStyle.normal,
                                          foreground: paint,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colori.primario)),
                                      onPressed: () async {
                                        if (_formKey.currentState.validate() &&
                                            _confermaPasswordController.text ==
                                                _passwordController.text) {
                                          try {
                                            await _register();
                                          } catch (err) {
                                            setState(() {
                                              _err = err.message;
                                              _success = false;
                                            });
                                          }
                                        } else {
                                          setState(() {
                                            _err =
                                                "Le password devono corrispondere!";
                                            _success = false;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: Text(_success == null
                                    ? ''
                                    : (_success
                                        ? 'Registrazione avvenuta con successo!\n $_userEmail'
                                        : _err)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<void> _register() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    ))
        .user;
    if (user != null) {
      var params = {
        "uid": user.uid.toString(),
        "nome": _nomeController.text,
        "cognome": _cognomeController.text
      };
      http.post(Uri.https('thispensa.herokuapp.com', '/registrazione'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            "withCredential": "true",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Map data = jsonDecode(response.body);
        if (data["errore"]) {
          _success = false;
          _auth.currentUser.delete();
        } //se genera un'errore il server elimino l'account da firebase
        else {
          if (!user.emailVerified)
            await user.sendEmailVerification().then((value) => _auth.signOut());
          setState(() {
            _success = true;
            _userEmail = "Controlla la tua mail per confermare l'account";
            _emailController.text = "";
            _passwordController.text = "";
            _confermaPasswordController.text = "";
            _nomeController.text = "";
            _cognomeController.text = "";
          });
        }
      });
    } else
      _success = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    return Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Inserire una mail per continuare';
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (String value) {
                    if (value.isEmpty)
                      return 'Inserire una password per continuare';
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 33),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.send,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          "Accedi",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            foreground: paint,
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colori.primario)),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            await _signInWithEmailAndPassword();
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.border_color,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          "Registrati",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            foreground: paint,
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colori.primarioScuro)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RegisterPage()));
                        },
                      ),
                      SizedBox(height: 10),
                      SignInButton(Buttons.Google, onPressed: () async {
                        _signInWithGoogle();
                      }, text: "Accedi con Google"),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.help,
                          color: Colors.grey[400],
                        ),
                        label: Text(
                          "Password dimenticata",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            foreground: paint,
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colori.primarioScuro)),
                        onPressed: () async {
                          await _auth.sendPasswordResetEmail(
                              email: _auth.currentUser.email);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Email per resettare la password inviata. Controlla la tua casella.'),
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final GoogleAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(googleAuthCredential);
      }

      final user = userCredential.user;
      var params = {
        "uid": user.uid.toString(),
        "tokenJWT": await user.getIdToken()
      };
      http.post(
          Uri.https('thispensa.herokuapp.com', '/collegamentoAccountGoogle'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            "withCredential": "true",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Map data = jsonDecode(response.body);
        if (!data["errore"])
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyNavWidget()));
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accesso con google fallito: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user.emailVerified) {
        var params = {
          "uid": user.uid.toString(),
          "tokenJWT": await user.getIdToken()
        };
        http.post(Uri.https('thispensa.herokuapp.com', '/login'),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              "withCredential": "true",
              HttpHeaders.contentTypeHeader: "application/json"
            }).then((response) async {
          Map data = jsonDecode(response.body);
          if (!data["errore"]) {
            _emailController.text = "";
            _passwordController.text = "";
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => MyNavWidget()));
          } else
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Errore nel server durante il login"),
            ));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Prima bisogna verificare l'indirizzo email per poter continaure"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password o username errati'),
        ),
      );
    }
  }
}
