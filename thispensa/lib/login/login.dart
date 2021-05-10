import 'dart:convert';
import 'dart:io';
import '../style/colors.dart';
import '../nav/nav.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        primaryColor: Colori.primario,
      ),
      home: MyHomePage(title: 'Login'),
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
    FirebaseAuth.instance.authStateChanges().map((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        var params = {"uid": user.uid.toString()};
        http.post(Uri.https('thispensa.herokuapp.com', '/login'),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            }).then((response) async {
          Future.microtask(() => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyNavWidget()),
                (route) => false,
              ));
        });
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Accesso"),
      ),
      body: _EmailPasswordForm(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success;
  String _userEmail = '';
  String _err = "";
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrazione"),
      ),
      body: Form(
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
                      if (value.isEmpty) {
                        return 'Inserisci una mail per continuare';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Inserisci una password per continuare';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: SignInButtonBuilder(
                      icon: Icons.person_add,
                      backgroundColor: Colors.lightBlue,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          try {
                            await _register();
                          } catch (err) {
                            setState(() {
                              _err = err.message;
                              _success = false;
                            });
                          }
                        }
                      },
                      text: 'Register',
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
        "nome": "prendere da textbox",
        "cognome": "prendere da textbox"
      };
      http.post(Uri.http('thispensa.herokuapp.com', '/registrazione'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Map data = jsonDecode(response.body);
        if (data["errore"]) {
          _success = false;
          _auth.currentUser.delete();
        } //se genera un'errore il server elimino l'account da firebase
        else {
          if (!user.emailVerified) {
            await user.sendEmailVerification();
          }
          _auth.signOut();
          setState(() {
            _success = true;
            _userEmail = "Controlla la tua mail per confermare l'account";
          });
        }
      });
    } else {
      _success = false;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class loginPage extends StatefulWidget {
  @override
  _loginPage createState() => _loginPage();
}

class _loginPage extends State<loginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accedi")),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            _EmailPasswordForm(),
            SignInButton(Buttons.Google, onPressed: () async {
              _signInWithGoogle();
            }),
          ],
        );
      }),
    );
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
      var params = {"uid": user.uid.toString()};
      http.post(
          Uri.https(
              'thispensa.herokuapp.com', '/collegamentoAccountGoogle'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyNavWidget()),
          (route) => false,
        );
      });

      /*
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Accesso con google avvenuto con successo'),
      ));*/
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accesso con google fallito: $e'),
        ),
      );
    }
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
    return Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Accedi con email e password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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

                //button to login
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  child: SignInButton(
                    Buttons.Email,
                    text: 'Sign In',
                    onPressed: () async {
                    
                      if (_formKey.currentState.validate()) {
                        await _signInWithEmailAndPassword();
                      }
                    },
                  ),
                ),

                //button to register
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: SignInButtonBuilder(
                    icon: Icons.person_add,
                    backgroundColor: Colori.scuro,
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RegisterPage()));
                    },
                    text: 'Register',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: SignInButton(Buttons.Google, onPressed: () async {
                    _signInWithGoogle();
                  }),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      var params = {"uid": user.uid.toString()};
      http.post(
          Uri.http(
              'thispensa.herokuapp.com', '/collegamentoAccountGoogle'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyNavWidget()),
          (route) => false,
        );
      });

      /*
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Accesso con google avvenuto con successo'),
      ));*/
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accesso con google fallito: $e'),
        ),
      );
    }
  }

  // Example code of how to sign in with email and password.
  Future<void> _signInWithEmailAndPassword() async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user.emailVerified) {
        var params = {"uid": user.uid.toString()};
        print(params);
        http.post(Uri.https('thispensa.herokuapp.com', '/login'),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            }).then((response) async {
          Map data = jsonDecode(response.body);
          if (!data["errore"])
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyNavWidget()),
              (route) => false,
            );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Prima bisogna verificare l'indirizzo email per poter continaure"),
        ));
      }
      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accesso avvenuto con successo'),
        ),
      );
      */
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password o username errati'),
        ),
      );
    }
  }
}
