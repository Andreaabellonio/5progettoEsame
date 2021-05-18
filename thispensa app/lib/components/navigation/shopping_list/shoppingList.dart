import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../styles/colors.dart';
import 'tasks/add_task_screen.dart';

class MyListWidget extends StatefulWidget {
  @override
  _MyListWidgetState createState() => _MyListWidgetState();
}

class _MyListWidgetState extends State<MyListWidget> {
Widget _buildTask(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text('Task Title'),
            subtitle: Text('May 2, 2021'),
            trailing: Checkbox(
              onChanged: (value) {
                print(value);
              },
              activeColor: Theme.of(context).primaryColor,
              value: true,
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colori.primario,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddTaskScreen())),
      ),
      body: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('my tasks',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    Text('1 of 10',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }
            return _buildTask(index);
          }),
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
