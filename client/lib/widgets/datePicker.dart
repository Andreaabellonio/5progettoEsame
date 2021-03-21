import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  Function(TextEditingController) callback;
  String data;
  DatePicker(this.data, this.callback);

  @override
  _DatePickerState createState() => _DatePickerState(data);
}

class _DatePickerState extends State<DatePicker> {
  final dateController = TextEditingController();

  _DatePickerState(data) {
    
      dateController.text = data;
   
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: TextField(
      readOnly: true,
      controller: dateController,
      decoration: InputDecoration(hintText: 'Pick your Date'),
      onTap: () async {
        var date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100));
        dateController.text = date.toString().substring(0, 10);
        widget.callback(dateController);
      },
    ));
  }
}
