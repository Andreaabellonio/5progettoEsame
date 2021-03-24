import 'package:flutter/material.dart';
//file puntatori al'origine'
import 'package:fstsheet/user/screens/screens.dart';

Widget versionApp() {
  return Container(
    padding: EdgeInsets.symmetric(
      vertical: 250.0,
    ),
    child: Column(children: [
      Icon(
        Icons.developer_board,
        size: 100,
      ),
      Text(
        "vv. 0.0.3",
        textAlign: TextAlign.end,
        style: TextStyle(fontSize: 20),
      ),
    ]),
  );
}
