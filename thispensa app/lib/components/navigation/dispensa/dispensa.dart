import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thispensa/models/dispensa_model.dart';
import 'package:thispensa/models/post_model.dart';
import '../../../styles/colors.dart';
import 'package:numberpicker/numberpicker.dart';
import 'chiamateServer/http_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyDispensa extends StatefulWidget {
  @override
  _MyDispensaState createState() => _MyDispensaState();
}

class _MyDispensaState extends State<MyDispensa> {
  final HttpService httpService = HttpService();
  List<Widget> oggetti;
  String idDispensa;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colori.primario,
                ),
                child: Text(
                  'Dispense',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              FutureBuilder(
                future: httpService.getDispense(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Dispensa>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    List<Dispensa> posts = snapshot.data;
                    if (posts.length > 0) {
                      idDispensa = posts[0].id;
                      List<Widget> oggetti = posts
                          .map((Dispensa dispensa) => ListTile(
                                leading: Icon(Icons.text_snippet),
                                title: Text(dispensa.nome),
                                onTap: () {
                                  setState(() {
                                    idDispensa = dispensa.id;
                                  });
                                },
                              ))
                          .toList();
                      return new ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: oggetti.length,
                        itemBuilder: (BuildContext context, int index) {
                          return oggetti[index];
                        },
                      );
                    } else {
                      return Text("Nessuna dispensa presente");
                    }
                  }
                },
              ),
            ],
          ),
        ),
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
              idDispensa != null
                  ? FutureBuilder(
                      future: httpService.getPosts(idDispensa),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Post>> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          List<Post> posts = snapshot.data;
                          List<Widget> oggetti = posts
                              .map(
                                (Post post) => _itemBuilder(post),
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
                      })
                  : Text('Seleziona dispensa'),
            ],
          ),
        )));
  }

  Widget _itemBuilder(Post post) {
    return Container(
      child: Stack(
        //alignment: AlignmentDirectional.bottomEnd,
        children: [
          TileOverlay(post),
        ],
      ),
    );
  }
}

class TileOverlay extends StatelessWidget {
  final Post post;
  TileOverlay(this.post);
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
              child: PostTile(post: post)),
        )
      ],
    );
  }
}

class PostTile extends StatefulWidget {
  PostTile({this.post});

  final Post post;
  @override
  _PostTileState createState() => new _PostTileState(post: post);
}

//----------------------------------------------------------------------------------------//

class _PostTileState extends State<PostTile> {
  _PostTileState({
    this.post,
  }); //!default value, parametri tra {} vuol dire che sono opzionali
  final Post post;
  final String postsURL =
      "https://thispensa.herokuapp.com/aggiornaProdottoDispensa";

  @override
  Widget build(BuildContext context) {
    //costruzione item dove inserire il NOME del prodotto
    final nameItem = Container(
      width: 150,
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(left: 12.0),
      child: Text(
        post.name.toUpperCase(),
        //style: Theme.of(context).textTheme.bodyText1,
        style: TextStyle(
          fontSize: 14,
        ),
        overflow: TextOverflow.fade,
        //textAlign: TextAlign.justify,
      ),
    );

    final numberPicker = NumberPicker(
      textStyle: TextStyle(fontSize: 12),
      value: post.qta,
      minValue: 0,
      maxValue: 100,
      step: 1,
      itemHeight: 50,
      itemWidth: 50,
      axis: Axis.horizontal,
      onChanged: (value) => setState(() => post.qta = value),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26),
      ),
    );

    final trash = IconButton(
      alignment: Alignment.centerRight,
      icon: Icon(Icons.delete),
      color: Colori.scuro,
      iconSize: 35,
      onPressed: () async {
        var params = {
          "barcode": post.barcode,
          "number": numberPicker.value,
          "uid": _auth.currentUser.uid.toString(),
          "tokenJWT": await _auth.currentUser.getIdToken(),
        };
        print(params);

        http.Response res = await http.post(Uri.parse(postsURL),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            });

        //Response res = await get(postsURL);
        if (res.statusCode == 200) {
          dynamic body = jsonDecode(res.body);

          List<dynamic> lista = body["prodotti"];
          print(lista);
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
                        children: [
                          numberPicker,
                          trash,
                        ],
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
