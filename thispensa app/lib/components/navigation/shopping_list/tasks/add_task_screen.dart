import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../styles/colors.dart';
import 'package:thispensa/components/productWidgets/barcode_scan2.dart';

class AddTaskScreen extends StatefulWidget {
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
    super.initState();
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

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

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title' + '$_date' + '$_priority');
      //aggiungere l'elemento al db

      //aggiornare l'elemento

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Barcode(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 30.0,
                    color: Colori.primario,
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Add Task',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
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
                          validator: (input) => input.trim().isEmpty
                              ? 'Please enter a task title'
                              : null,
                          onSaved: (input) => _title = input,
                          initialValue: _title,
                        ),
                      ),
                      //date
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 18.0),
                          onTap: _handDatePicker,
                          decoration: InputDecoration(
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
                          items: _priorities.map((String priority) {
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
                            'Add',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          onPressed: _submit,
                        ),
                      )
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
