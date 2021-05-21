import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_signin_button/button_builder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home page'),
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
    if (_auth.currentUser == null) {
      print('User is currently signed out!');
    } else {
      if (_auth.currentUser.emailVerified) {
        var params = {"uid": _auth.currentUser.uid.toString()};
        http.post(Uri.http('192.168.1.53:23377', '/login'),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            }).then((response) async {
          Map data = jsonDecode(response.body);
          if (!data["errore"])
            Future.microtask(() => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => userPage())));
        });
      }
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("BEH"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => registerPage()));
                },
                child: Text("REGISTRATI")),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => loginPage()));
                },
                child: Text("ACCEDI"))
          ],
        ),
      ),
    );
  }
}

class registerPage extends StatefulWidget {
  @override
  _registerPage createState() => _registerPage();
}

class _registerPage extends State<registerPage> {
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
      http.post(Uri.http('192.168.1.53:23377', '/registrazione'),
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
            await user.sendEmailVerification().then((value) => _auth.signOut());
          }
          setState(() {
            _success = true;
            _userEmail = "Controlla la tua mail per confermare l'account";
            _emailController.text = "";
            _passwordController.text = "";
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
      http.post(Uri.http('192.168.1.53:23377', '/collegamentoAccountGoogle'),
          body: json.encode(params),
          headers: {
            "Accept": "application/json",
            HttpHeaders.contentTypeHeader: "application/json"
          }).then((response) async {
        Map data = jsonDecode(response.body);
        if (!data["errore"])
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => userPage()));
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
        http.post(Uri.http('192.168.1.53:23377', '/login'),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            }).then((response) async {
          Map data = jsonDecode(response.body);
          if (!data["errore"])
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => userPage()));
          else
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

class userPage extends StatefulWidget {
  @override
  _userPage createState() => _userPage();
}

class _userPage extends State<userPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("USER PAGE"),
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: () async {
                print("UE");
                print(_auth.currentUser);
                final User user = _auth.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Nessuno loggato'),
                  ));
                  return;
                }
                await _signOut();
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
/*
                final String uid = user.uid;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('logout avvenuto con successo'),
                ));
                */
              },
              icon: Icon(Icons.logout),
            );
          })
        ],
      ),
      body: Column(children: <Widget>[
        Container(
          padding: EdgeInsets.all(50),
          child: Text(_auth.currentUser.email),
        ),
        TextButton(
            child: Text("Resetta password"),
            onPressed: () async {
              await _auth.sendPasswordResetEmail(
                  email: _auth.currentUser.email);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Email per resettare la password inviata'),
              ));
              await _signOut();
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            }),
        TextButton(
            child: Text("Elimina account"),
            onPressed: () async {
              try {
                //! GESTIONE ELIMINAZIONE ACCOUNT DA MONGO
                await _auth.currentUser.delete();
              } catch (e) {
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Accesso con google fallito: $e'),
                  ),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Account eliminato'),
              ));
              await _signOut();
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()));
            })
      ]),
    );
  }

  Future<void> _signOut() async {
    http.post(Uri.http('192.168.1.53:23377', '/logout'), headers: {
      "Accept": "application/json",
      HttpHeaders.contentTypeHeader: "application/json"
    }).then((response) async {
      await _auth.signOut();
    });
  }
}
