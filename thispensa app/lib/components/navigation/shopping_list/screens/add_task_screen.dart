import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:thispensa/styles/colors.dart';
import '../models/task_model.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AddTaskScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;
  final callback;
  AddTaskScreen({this.updateTaskList, this.task, void refresh()})
      : callback = refresh;
  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  int _qta = 1;
  String _priority;

  final List<String> _priorities = ['Bassa', 'Media', 'Alta'];

  @override
  void initState() {
    //nel caso la task sia nuova carica solo la data, in caso contrario
    super.initState();
    if (widget.task != null) {
      _title = widget.task.title;
      _qta = widget.task.qta;
      _priority = widget.task.priority;
    }
  }

  _delete() async {
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.foldingCube;
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show();
    String postsURL =
        "https://thispensa.herokuapp.com/eliminaProdottoListaSpesa";
    var params = {
      "idProdotto": widget.task.id,
      "uid": _auth.currentUser.uid.toString(),
      "tokenJWT": await _auth.currentUser.getIdToken()
    };
    //? Richiesta post al server node con parametri
    Response res = await post(Uri.parse(postsURL),
        body: json.encode(params),
        headers: {
          "Accept": "application/json",
          HttpHeaders.contentTypeHeader: "application/json"
        });

    //Response res = await get(postsURL);
    if (res.statusCode == 200) {
      dynamic body = jsonDecode(res.body);
      if (body["errore"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Errore nell\'esecuzione della chiamata sul server'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Errore nel server, riprovare più tardi!'),
        ),
      );
    }

    await widget.callback();
    Navigator.pop(context);
    EasyLoading.dismiss();
  }

  //update e add
  _submit() async {
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.foldingCube;
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show();
    //aggiunta o aggiornamento dei valori nel documento 'task_model.dart'
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      //assegno i valori
      Task task = Task(title: _title, qta: _qta, priority: _priority);

      if (widget.task == null) {
        //se l'elemento non esiste lo creo
        task.status = 0; //per indicare che non è ancora checkata
        aggiungiTask(task);
      } else {
        //se l'oggetto esiste aggiorno la task
        task.id = widget.task.id;
        task.status = widget.task.status;
        modificaTask(task);
      }

      //aggiornare l'elemento
      await widget
          .callback(); //utilizzato per essere sicuri che si aggiorni la pagina principale
      Navigator.pop(context);
      EasyLoading.dismiss();
    }
  }

  void aggiungiTask(Task task) async {
    String postsURL =
        "https://thispensa.herokuapp.com/inserisciProdottoListaSpesa";
    var params = {
      "status": task.status,
      "titolo": task.title,
      "qta": task.qta,
      "priorita": task.priority,
      "uid": _auth.currentUser.uid.toString(),
      "tokenJWT": await _auth.currentUser.getIdToken()
    };
    //? Richiesta post al server node con parametri
    Response res = await post(Uri.parse(postsURL),
        body: json.encode(params),
        headers: {
          "Accept": "application/json",
          HttpHeaders.contentTypeHeader: "application/json"
        });

    //Response res = await get(postsURL);
    if (res.statusCode == 200) {
      dynamic body = jsonDecode(res.body);
      if (body["errore"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Errore nell\'esecuzione della chiamata sul server'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Errore nel server, riprovare più tardi!'),
        ),
      );
    }
  }

  void modificaTask(Task task) async {
    String postsURL =
        "https://thispensa.herokuapp.com/aggiornaProdottoListaSpesa";
    var params = {
      "idProdotto": task.id,
      "status": task.status,
      "titolo": task.title,
      "qta": task.qta,
      "priorita": task.priority,
      "uid": _auth.currentUser.uid.toString(),
      "tokenJWT": await _auth.currentUser.getIdToken()
    };
    //? Richiesta post al server node con parametri
    Response res = await post(Uri.parse(postsURL),
        body: json.encode(params),
        headers: {
          "Accept": "application/json",
          HttpHeaders.contentTypeHeader: "application/json"
        });

    //Response res = await get(postsURL);
    if (res.statusCode == 200) {
      dynamic body = jsonDecode(res.body);
      if (body["errore"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Errore nell\'esecuzione della chiamata sul server'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Errore nel server, riprovare più tardi!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        //quando si sta scrivendo in una textbox si può uscire da questa anche solo cliccando lo sfondo dell'ambiente
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //freccia per tornare indietro
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 30.0,
                    color: Colori.primario,
                  ),
                ),
                SizedBox(height: 20.0),

                //titolo della pagina
                Text(
                  //se non esiste l'oggetto la scritta mostrerà 'AddTask' nel caso esista mostrerà 'Update Task'
                  widget.task == null
                      ? 'Aggiungi prodotto'
                      : 'Aggiorna prodotto',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),

                //inserimento degli elementi della Task
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //title
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Titolo',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          //toglie gli spazi per osservare che ci sia o meno scritto qualcosa
                          validator: (input) => input == ""
                              ? 'Inserisci un titolo per continuare'
                              : null,
                          onChanged: (input) => _title = input,
                          initialValue:
                              _title, //inserirsce il valore di _title nella textbox (utile nel caso esistesse già il task)
                        ),
                      ),

                      NumberPicker(
                        value: _qta,
                        minValue: 1,
                        maxValue: 100,
                        step: 1,
                        itemHeight: 70,
                        itemWidth: 70,
                        axis: Axis.horizontal,
                        onChanged: (value) => setState(() => _qta = value),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => setState(() {
                              if (_qta > 1) {
                                final newValue = _qta - 1;
                                _qta = newValue.clamp(0, 100);
                              }
                            }),
                          ),
                          Text('Quantità Prodotto'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => setState(() {
                              if (_qta < 100) {
                                final newValue = _qta + 1;
                                _qta = newValue.clamp(0, 100);
                              }
                            }),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          iconSize: 22.0,
                          iconEnabledColor: Colori.primario,
                          icon: Icon(Icons.arrow_drop_down_circle),
                          //prendo 'High || Medium || Low'
                          items: _priorities.map((String priority) {
                            //impostazione dei valori nella lista
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(priority,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18.0)),
                            );
                          }).toList(),
                          style: TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Priorità',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          validator: (input) => _priority == null
                              ? 'Inserisci una priorità per continuare'
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value;
                            });
                          },
                          value: _priority,
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colori.primario,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: TextButton(
                          child: Text(
                            widget.task == null
                                ? 'Aggiungi'
                                : 'Aggiorna', //se isiste già l'oggetto ='Update / se non esiste = 'Add'
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          onPressed: _submit,
                        ),
                      ),

                      //nel caso esista già la task aggiungo un bottone 'Elimina'
                      widget.task != null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 20.0),
                              height: 60.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colori.primario,
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: TextButton(
                                child: Text(
                                  'Elimina',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                                onPressed: _delete,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
