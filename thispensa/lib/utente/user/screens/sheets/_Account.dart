import 'package:flutter/material.dart';
//import 'package:flutter_image_ppicker/home_screen.dart';
//file puntatori al'origine'
import '../screens.dart';



  class AccountState extends State<Account> {

  final _nameController = TextEditingController(
    text: 'Nome', //ENRICO: inserimento del nome dell'utente
  );

  final _surnameController = TextEditingController(
    text: 'Cognome', //ENRICO: inserimento del cognome dell'utente
  );

  final _emailController = TextEditingController(
    text: 'Email', //ENRICO: inserimento della mail dell'utente
  );

//funzione per la creazione delle textbox
  Widget textBoxController(String text, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(8.0), //padding da tutti i lati di 8
      child: TextField(
        controller: controller, //testo all'interno della textbox
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: Colors.grey,
            height: 0.5,
          ),
          //contorno attorno alla textbox
          //border: OutlineInputBorder(), //arrotondamento degli angoli
          labelText: text, //miniatura della scritta
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            /*new Container(
                height: 80.0,
                width: 80.0,
                child: new Image.asset('/assets/images/cactus.jpg'),
                decoration: new BoxDecoration(
                    color: const Color(0xff7c94b6),
                    borderRadius: BorderRadius.all(const Radius.circular(50.0)),
                    border: Border.all(color: const Color(0xFF28324E)),
                ),

                ),*/

            //CREAZIONE DELLE DUE TEXTBOX
            textBoxController("Nome", _nameController),
            textBoxController("Cognome", _surnameController),
            textBoxController("E-Mail", _emailController),

            Container(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                child: Text("Save"),
                onPressed: () {
                  setState(() {
                    //ENRICO: salvataggio delle informazioni nel DB
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
