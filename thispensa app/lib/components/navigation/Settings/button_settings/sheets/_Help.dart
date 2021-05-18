import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
//file puntatori al'origine'
import '../stgButton.dart';

class HelpState extends State<Help> {
  List<String> attachments = [];

//email di colui che riceve
  final _recipientController = TextEditingController(
    text: 'g.cerato.1010@vallauri.edu',
  );

//OGGETTO del messaggio
  final _objController = TextEditingController(text: 'The object');

//TESTO della mail
  final _bodyController = TextEditingController(
    text: 'Mail body.',
  );

//struttura della mail
  Future<void> send() async {
    final Email email = Email(
      body: _bodyController.text,
      subject: _objController.text,
      recipients: [_recipientController.text],
      attachmentPaths: attachments,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'success';
    } catch (error) {
      platformResponse = error.toString();
    }

    //snackbar con indicazione di errore o successo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatta il responsabile'),
        actions: <Widget>[
          //Send icon che si collega alla mail
          IconButton(
            onPressed: send,
            icon: Icon(Icons.send),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            //CREAZIONE DELLE DUE TEXTBOX
            Padding(
              padding: EdgeInsets.all(8.0), //padding da tutti i lati di 8
              child: TextField(
                controller: _objController, //testo all'interno della textbox
                decoration: InputDecoration(
                  //contorno attorno alla textbox
                  border: OutlineInputBorder(), //arrotondamento degli angoli
                  labelText: 'Oggetto', //miniatura della scritta
                ),
              ),
            ),
            Expanded(
              //copertura dell'intero spazio disponibile
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                      labelText: 'Body', border: OutlineInputBorder()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}