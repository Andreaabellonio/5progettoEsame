import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DatePicker extends StatefulWidget {
  Function(TextEditingController) callback;
  TextEditingController data;
  DatePicker(this.data, this.callback);

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    dateController = widget.data;
    return new Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 152,
        child: TextField(
          readOnly: true,
          controller: dateController,
          decoration: InputDecoration(
            hintText: 'Data di scadenza',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
          onTap: () async {
            var date = await showDatePicker(
                context: context,
                initialDate: dateController.text == ""
                    ? DateTime.now()
                    : DateTime.parse(dateController.text),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100));
            dateController.text =
                (date.toString() != '') ? date.toLocal().toString().split(' ')[0] : "";
            widget.callback(dateController);
          },
        ),
      ),
    );
  }
}
