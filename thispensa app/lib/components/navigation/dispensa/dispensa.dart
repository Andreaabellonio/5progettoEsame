import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prompt_dialog/prompt_dialog.dart';
import '../../../styles/colors.dart';
import '../../../models/dispensa_model.dart';
import 'package:numberpicker/numberpicker.dart';
import 'chiamateServer/http_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyDispensa extends StatefulWidget {
  MyDispensa({Key key}) : super(key: key);

  @override
  _MyDispensaState createState() => _MyDispensaState();
}

class _MyDispensaState extends State<MyDispensa> {
  final HttpService httpService = HttpService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colori.primario,
            child: Icon(Icons.add),
            onPressed: () async => {}),
        body: Container(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('my Items',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10.0),
              Text('just food',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 10.0),
              FutureBuilder(
                future: httpService.getDispense(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Dispensa>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    List<Dispensa> posts = snapshot.data;
                    List<Widget> oggetti = posts
                        .map(
                          (Dispensa dispensa) => _itemBuilder(dispensa),
                        )
                        .toList();
                    return new ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: oggetti.length,
                      itemBuilder: (BuildContext context, int index) {
                        return oggetti[index];
                      },
                    );
                  }
                },
              ),
            ],
          ),
        )));
  }

  Widget _itemBuilder(Dispensa dispensa) {
    return Container(
      child: Stack(
        //alignment: AlignmentDirectional.bottomEnd,
        children: [
          TileOverlay(dispensa),
        ],
      ),
    );
  }
}

class TileOverlay extends StatelessWidget {
  final Dispensa dispensa;
  TileOverlay(this.dispensa);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
              //padding: EdgeInsets.symmetric(vertical: 5.0),
              /*decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5)), //opacità tra 0 e 1*/
              child: DispensaTile(dispensa: dispensa)),
        )
      ],
    );
  }
}

class DispensaTile extends StatefulWidget {
  DispensaTile({this.dispensa});

  final Dispensa dispensa;
  @override
  _DispensaTileState createState() =>
      new _DispensaTileState(dispensa: dispensa);
}

//----------------------------------------------------------------------------------------//

class _DispensaTileState extends State<DispensaTile> {
  _DispensaTileState({
    this.dispensa,
  }); //!default value, parametri tra {} vuol dire che sono opzionali
  final Dispensa dispensa;

  @override
  Widget build(BuildContext context) {
    //costruzione item dove inserire il NOME del prodotto
    final nameItem = Container(
      width: 150,
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(left: 12.0),
      child: Text(
        dispensa.nome,
        //style: Theme.of(context).textTheme.bodyText1,
        style: TextStyle(
          fontSize: 14,
        ),
        overflow: TextOverflow.fade,
        //textAlign: TextAlign.justify,
      ),
    );

    final trash = IconButton(
      alignment: Alignment.centerRight,
      icon: Icon(Icons.delete),
      color: Colori.scuro,
      iconSize: 35,
      onPressed: () async {
        var params = {
          "idDispensa": dispensa.id,
          "uid": _auth.currentUser.uid.toString(),
          "tokenJWT": await _auth.currentUser.getIdToken(),
        };
        print(params);
        String postsURL = "https://thispensa.herokuapp.com/eliminaDispensa";
        http.Response res = await http.post(Uri.parse(postsURL),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            });

        //Response res = await get(postsURL);
        if (res.statusCode == 200) {
          dynamic body = jsonDecode(res.body);

          print(body);
        } else {
          throw "Unable to retrieve posts.";
        }
      },
    );

    return Column(
      children: [
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          margin: const EdgeInsets.only(left: 6.0, right: 6.0),
          decoration: BoxDecoration(
            color: Colori.primarioTenue,
            borderRadius: BorderRadius.circular(10),
            //border: Border.all(color: Colors.black26),
          ),
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //SizedBox(height: 16)

                    nameItem,

                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        //mainAxisAlignment: MainAxisAlignment.value(),
                        children: [trash],
                      ),
                    ),
                  ],
                ),
              ]),
        ),
        //Divider(color: Colors.grey, height: 32),
      ],
    );
  }
}
