import 'package:flutter/material.dart';
import '../../style/colors.dart';

class Specs extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SPECS"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: 22.0, top: 33.0, right: 22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            //alignment: AlignmentDirectional.bottomEnd,
            children: [
              Text(
                'pgfpfgp',
                style: TextStyle(
                    fontFamily: 'RaleWay',
                    fontSize: 25,
                    decoration: TextDecoration.underline),
              )
            ],
          ),
        ),
      ),
    );
  }
}

