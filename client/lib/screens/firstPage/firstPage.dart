import 'package:flutter/material.dart';
import 'package:client/screens/secondPage/secondPage.dart';
import 'package:client/widgets/barcode_scan2.dart';
import 'package:client/widgets/dialog.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ThisPensa'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Benvenuto',
                style: TextStyle(fontSize: 50),
              ),
              RaisedButton(
                child: Text('Fatti un viaggio'),
                onPressed: () {
                  // Pushing a route directly, WITHOUT using a named route
                  Navigator.of(context).push(
                    // With MaterialPageRoute, you can pass data between pages,
                    // but if you have a more complex app, you will quickly get lost.
                    MaterialPageRoute(
                      builder: (context) =>
                          SecondPage(data: 'Hello there from the first page!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      floatingActionButton:Barcode() ,

       );
  }
}
