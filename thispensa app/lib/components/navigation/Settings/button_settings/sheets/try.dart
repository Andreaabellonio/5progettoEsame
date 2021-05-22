import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';


class Picture extends StatefulWidget {
  Picture({Key key}) : super(key: key);

  @override
  _Picture createState() => _Picture();
}

class _Picture extends State<Picture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('prova'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // testing for child widget which is using FlutterLogo
              CircularProfileAvatar(
                null,
                child: FlutterLogo(),
                borderColor: Colors.purpleAccent,
                borderWidth: 2,
                elevation: 5,
                radius: 50,
              ),
              CircularProfileAvatar(
                null,
                child: Icon(
                  Icons.person,
                  size: 140,
                ),
                borderColor: Colors.black,
                borderWidth: 3,
                elevation: 5,
                radius: 75,
              ),
              CircularProfileAvatar(
//                  'https://avatars0.githubusercontent.com/u/8264639?s=460&v=4',
                'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRWtMDksH9GzFdMinyAkGbtLJNx6xynLETTNN5akjxirL3QD5Rj',
                errorWidget: (context, url, error) => Container(
                  child: Icon(Icons.error),
                ),
                placeHolder: (context, url) => Container(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
                radius: 90,
                backgroundColor: Colors.transparent,
                borderWidth: 10,
//                  initialsText: Text(
//                    "AD",
//                    style: TextStyle(fontSize: 40, color: Colors.white),
//                  ),
                borderColor: Colors.red,
                elevation: 5.0,
                onTap: () {
                  print('adil');
                },
                cacheImage: true,
                showInitialTextAbovePicture: false,
              ),
            ],
          ),
        ));
  }
}