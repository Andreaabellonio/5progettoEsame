import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thispensa/components/navigation/dispensa/chiamateServer/http_service.dart';
import 'package:thispensa/styles/colors.dart';
import 'screens/add_task_screen.dart';
import 'models/task_model.dart';

class MyListWidget extends StatefulWidget {
  @override
  _MyListWidgetState createState() => _MyListWidgetState();
}

class _MyListWidgetState extends State<MyListWidget> {
  final HttpService httpService = HttpService();
  ListView elencoTask;
  List<Task> listaTask;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    setState(() {
      listaTask = []; //CHI TOCCA MUORE: senza questa schifezza non va nulla
    });
    caricaListaSpesa();
    if (mounted) {
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          refreshController.refreshCompleted();
        });
      });
    }
  }

  void _onLoading() async {
    if (mounted) {
      caricaListaSpesa();
      refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    onRefresh();
    super.initState();
  }

  void caricaListaSpesa() async {
    listaTask = await httpService.getTasks();

    List<Widget> oggetti = listaTask
        .map(
          (Task task) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                Container(
                  height: 60,
                  child: ListTile(
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
                      '${task.qta} + ${task.priority}',
                      style: TextStyle(
                        fontSize: 15.0,
                        decoration: task.status == 0
                            ? TextDecoration.none
                            : TextDecoration
                                .lineThrough, //linea sopra l'item se checkato
                      ),
                    ),
                    trailing: Checkbox(
                      onChanged: (value) async {
                        EasyLoading.instance.indicatorType =
                            EasyLoadingIndicatorType.foldingCube;
                        EasyLoading.instance.userInteractions = false;
                        EasyLoading.show();
                        task.status = value ? 1 : 0;
                        await AddTaskScreenState().modificaTask(task);
                        await onRefresh();
                        EasyLoading.dismiss();
                        //si ricaricano i task
                      },
                      activeColor: Theme.of(context).primaryColor,
                      value: task.status == 1 ? true : false,
                    ),
                    //click sulla TASK per modifica o eliminazione
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        //richiamo al documento 'add_task_screen' per la visione della pagina (aggiunta || elimina || modifica)
                        builder: (_) => AddTaskScreen(
                            updateTaskList: _updateTaskList,
                            task: task,
                            refresh: onRefresh),
                      ),
                    ),
                  ),
                ),
                Container(height: 20, child: Divider()),
              ],
            ),
          ),
        )
        .toList();

    var app = new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: oggetti.length,
      itemBuilder: (BuildContext context, int index) {
        return oggetti[index];
      },
    );

    setState(() {
      elencoTask = app;
    });
  }

  _updateTaskList() {
    //_taskList = DatabaseHelper.instance.getTaskList();
  }

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
                builder: (context) => AddTaskScreen(
                    updateTaskList: _updateTaskList,
                    refresh:
                        onRefresh) //riderimento al documento 'add_task_screen'
                )),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //i primi due punti sono solo per l'intestazione
            children: [
              Text('Lista della spesa',
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
              (elencoTask != null)
                  ? elencoTask
                  : Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
