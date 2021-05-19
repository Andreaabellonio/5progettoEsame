import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'helpers/database_helper.dart';
import 'screens/add_task_screen.dart';
import 'models/task_model.dart';
import 'style/colors.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyListWidget(),
    );
  }
}

class MyListWidget extends StatefulWidget {
  @override
  _MyListWidgetState createState() => _MyListWidgetState();
}

class _MyListWidgetState extends State<MyListWidget> {
  Future<List<Task>> _taskList; //lista di istanze della classe task_model.dart
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    _updateTaskList();
  }

  _updateTaskList() {
    _taskList = DatabaseHelper.instance.getTaskList(); 
  }

  //richiamato dalla ListView da 'Widget build'
  //si vanno a stampare i task
  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18.0,
                //nel caso sia spuntata la checkbox tira una riga sopra il task
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text( 
              //stampa la data con affianco la priorità -> '12/05/2021 • Low priority'
              '${_dateFormatter.format(task.date)} + ${task.priority}',
              style: TextStyle(
                fontSize: 15.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough, //linea sopra l'item se checkato
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task); //se viene checkata si fa un richiamo al db ('database_helper.dart)
                _updateTaskList(); //si ricaricano i task
              },
              activeColor: Theme.of(context).primaryColor,
              value: task.status == 1 ? true : false,
            ),
            //click sulla TASK per modifica o eliminazione
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                //richiamo al documento 'add_task_screen' per la visione della pagina (aggiunta || elimina || modifica)
                builder: (_) => AddTaskScreen( updateTaskList: _updateTaskList,
                  task: task,
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
/*
  Widget titleList(int did, int tot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('my tasks',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10.0),
          Text('$did of $tot',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }*/

  //si parte da qui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //floatingButton per l'aggiunta dei task
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colori.primario,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTaskScreen(updateTaskList: _updateTaskList,) //riderimento al documento 'add_task_screen'
                )),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //i primi due punti sono solo per l'intestazione
            children: [
              Text('My Shopping List',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Text('All Your Stuff',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 20.0),
              //qua avviene la stampa dei task
              FutureBuilder(
                future: _taskList,
                builder: (context, snapshot) {
                  /*if (!snapshot.hasData) {
                return titleList(0, 0);
              }*/
                  /*final int conpletedTaskCount = snapshot.data
                      .where((Task task) => task.status == 1)
                      .toList()
                      .length;*/
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(50.0),
                      //child: Center(child: Text('Nothing to Buy Here')),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return ListView.builder(
                        //padding: EdgeInsets.symmetric(vertical: 20.0),
                        itemCount: 1 + snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          /*if (index == 0) {
                      return titleList(conpletedTaskCount, snapshot.data.length);
                    }*/
                          return _buildTask(snapshot.data(index - 1));
                        });
                    
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
Container(
              margin: EdgeInsets.all(10.0),
                height: 20.0, 
                width: double.infinity, 
                color: Colori.primarioTenue);
                 */
