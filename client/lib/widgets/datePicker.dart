import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  Function(TextEditingController) callback;
  TextEditingController data;
  DatePicker(this.data, this.callback);

  @override
  _DatePickerState createState() => _DatePickerState(data);
}

class _DatePickerState extends State<DatePicker> {
  TextEditingController dateController = TextEditingController();

  _DatePickerState(data) {
    dateController = data;
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
            initialDate: dateController.text == ""
                ? DateTime.now()
                : DateTime.parse(dateController.text),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        dateController.text = date.toLocal().toString().split(' ')[0];
        widget.callback(dateController);
      },
    ));
  }
}
