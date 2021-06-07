import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

import 'dart:convert';
import 'package:http/http.dart';
import '../../../../models/dispensa_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class DatabaseHelper {
  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colQta = 'qta';
  String colPriority = 'property';
  String colStatus = 'status';

  Future<List<Task>> getTaskList() async {
    /*final List<Map<String, dynamic>> taskMapList = await getTaskMapList(); //crea una lista con gli oggetti presi dalla tabella contenente i task
    final List<Task> taskList = [];
    //creo le istanze delle classi
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap)); //richiamo al documento task_model
    });
    return taskList;*/

    String postsURL = "https://thispensa.herokuapp.com/leggiListaSpesa";
    var params = {
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
      //print(res.body);

      List<dynamic> lista = body["dati"];
      //print(lista);

      final List<Task> taskList = [];
      if (lista.length > 0)
        lista.forEach((taskMap) {
          taskList
              .add(Task.fromMap(taskMap)); //richiamo al documento task_model

          /*for (var i = 0; i < lista.length; i++) {
          taskList.add(Dispensa(
            id: lista[i]["_id"] as String,
            nome: lista[i]["nome"] as String,
            creator*e: lista[i]["creatore"] as String,
          ));*/
        });
      return taskList;
    } else {
      throw "Unable to retrieve Item.";
    }
  }

  /*Future<int> insertTask(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(tasksTable, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(tasksTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result =
        await db.delete(tasksTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }*/
}
