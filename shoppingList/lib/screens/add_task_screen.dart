import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/task_model.dart';
import '../style/colors.dart';

class AddTaskScreen extends StatefulWidget {

  final Function updateTaskList;
  final Task task;

  AddTaskScreen({this.updateTaskList, this.task});
  @override
  _AddTaskScreen createState() => _AddTaskScreen();
}

class _AddTaskScreen extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    //nel caso la task sia nuova carica solo la data, in caso contrario 
    super.initState();
    if(widget.task != null){
      _title=widget.task.title;
      _date=widget.task.date;
      _priority=widget.task.priority;
    }
    _dateController.text = _dateFormatter.format(_date);
  }
  @override
  void dispose(){
    _dateController.dispose();
    super.dispose();
  }

  //nel caso si volesse far scegliere la data all'utente viene richiamato nel TextForField della data (r.148)
  _handDatePicker() async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date).toString();
    }
  }

  _delete(){
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  _submit() { //aggiunta o aggiornamento dei valori nel documento 'task_model.dart'
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title' + '$_date' + '$_priority');
      //assegno i valori
      Task task= Task(title: _title, date: _date, priority:_priority);
      if(widget.task==null){ //se l'elemento non esiste lo creo
        task.status=0; //per indicare che non è ancora checkata
        DatabaseHelper.instance.insertTask(task); //richiamo a 'database_helper.dart'
      }
      else{ //se l'oggetto esiste aggiorno la task
        task.id=widget.task.id;
        task.status=widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }

      //aggiornare l'elemento
      widget.updateTaskList(); //utilizzato per essere sicuri che si aggiorni la pagina principale
      Navigator.pop(context);
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
                  widget.task==null ?'Add Task':'Update Task',
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
                            labelText: 'Title',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          //toglie gli spazi per osservare che ci sia o meno scritto qualcosa
                          validator: (input) => input.trim().isEmpty 
                              ? 'Please enter a task title'
                              : null,
                          onSaved: (input) => _title = input,
                          initialValue: _title, //inserirsce il valore di _title nella textbox (utile nel caso esistesse già il task)
                        ),
                      ),
                      //date
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18.0),
                          //onTap: _handDatePicker,
                          decoration: InputDecoration(
                            enabled: false,
                            labelText: 'Date',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                        ),
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
                            labelText: 'Priority',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          validator: (input) => _priority == null
                              ? 'Please select a priority level'
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
                            widget.task==null?'Add':'Update', //se isiste già l'oggetto ='Update / se non esiste = 'Add'
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          onPressed: _submit,
                        ),
                      ),

                      //nel caso esista già la task aggiungo un bottone 'Elimina'
                      widget.task!=null?Container(margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colori.primario,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: TextButton(
                          child: Text(
                            'Delete',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          onPressed: _delete,
                        ),): SizedBox.shrink(),
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
