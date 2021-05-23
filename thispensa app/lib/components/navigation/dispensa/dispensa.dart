import 'dart:convert';
import 'dart:io';
import 'package:Thispensa/components/login/popupDispensa/popupDispensa.dart';
import 'package:Thispensa/components/navigation/shopping_list/tasks/add_task_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:Thispensa/models/dispensa_model.dart';
import 'package:Thispensa/models/post_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String idDispensa;
  String nomeDispensa =
      ""; //carico dinamicamente il nome della dispensa selezionata
  ListView elencoDispense;
  List<Widget> oggetti2 = [];
  PopUpClass pop = new PopUpClass();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  Widget noElements = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Center(
          child: Text(
        "Ancora nessun prodotto presente!",
        style: TextStyle(fontSize: FontSize.xLarge.size),
      )));

  void _onRefresh() async {
    pop.first = false;
    setState(() {
      oggetti2 = []; //CHI TOCCA MUORE: senza questa schifezza non va nulla
    });
    await caricaDispense();
    if (mounted) {
      setState(() {
        _refreshController.refreshCompleted();
      });
    }
  }

  void _onLoading() async {
    if (mounted) {
      await caricaDispense();
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    EasyLoading.dismiss();
    pop.callback = caricaDispense;
    super.initState();
  }

  void caricaDispense() async {
    List<Dispensa> dispense = await httpService.getDispense();
    if (dispense.length == 0) {
      pop.first = true;
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return pop.popupDispensa(context);
          });
      _onRefresh(); //ricarico gli elementi dopo che ha inserito una nuova dispensa
      pop.first = false;
    } else {
      pop.first = false;

      Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      nomeDispensa = prefs.getString("nomeDispensa");
      idDispensa = prefs.getString("idDispensa");
      if (nomeDispensa == null || idDispensa == null) {
        nomeDispensa = dispense[0].nome;
        idDispensa = dispense[0].id;
      }

      List<Widget> oggetti = dispense
          .map(
            (Dispensa dispensa) => Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.20,
              child: ListTile(
                  leading: Icon(Icons.text_snippet),
                  title: Text(dispensa.nome),
                  onTap: () async {
                    EasyLoading.instance.indicatorType =
                        EasyLoadingIndicatorType.foldingCube;
                    EasyLoading.instance.userInteractions = false;
                    EasyLoading.show();
                    prefs.setString("idDispensa", dispensa.id);
                    prefs.setString("nomeDispensa", dispensa.nome);
                    List<Post> cose = await httpService.getPosts(dispensa.id);
                    if (cose.length > 0) {
                      setState(() {
                        oggetti2 = cose
                            .map(
                              (Post post) => _itemBuilder(post),
                            )
                            .toList();
                      });
                    } else {
                      oggetti2 = [noElements];
                    }
                    setState(() {
                      nomeDispensa = dispensa.nome;
                      idDispensa = dispensa.id;
                    });
                    Navigator.pop(context);
                    EasyLoading.dismiss();
                  }),
              actions: <Widget>[
                (_auth.currentUser.uid == dispensa.creatore)
                    ? IconSlideAction(
                        caption: 'Elimina',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text('ATTENZIONE!'),
                                    content: const Text(
                                        'Sei sicuro di voler eliminare DEFINITIVAMENTE la dispensa e tutti gli elementi al suo interno?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Annulla'),
                                        child: const Text('Annulla'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          EasyLoading.instance.indicatorType =
                                              EasyLoadingIndicatorType
                                                  .foldingCube;
                                          EasyLoading.instance
                                              .userInteractions = false;
                                          EasyLoading.show();
                                          try {
                                            var params = {
                                              "uid": _auth.currentUser.uid
                                                  .toString(),
                                              "tokenJWT": await _auth
                                                  .currentUser
                                                  .getIdToken(),
                                              "idDispensa": dispensa.id
                                            };
                                            http.post(
                                                Uri.https(
                                                    'thispensa.herokuapp.com',
                                                    '/eliminaDispensa'),
                                                body: json.encode(params),
                                                headers: {
                                                  "Accept": "application/json",
                                                  HttpHeaders.contentTypeHeader:
                                                      "application/json"
                                                }).then((response) async {
                                              Map data =
                                                  jsonDecode(response.body);
                                              if (!data["errore"]) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Dispensa eliminata con successo!"),
                                                  ),
                                                );
                                                //le pulisco così poi al prossimo refresh mi carica la prima dispensa
                                                prefs.remove("nomeDispensa");
                                                prefs.remove(
                                                    "idDispensa");
                                                await _onRefresh();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content: Text(
                                                        "Errore durante l'eliminazione"),
                                                  ),
                                                );
                                              }
                                              EasyLoading.dismiss();
                                              Navigator.pop(context);
                                            });
                                          } catch (e) {
                                            print(e);
                                            EasyLoading.dismiss();
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Errore durante l\'eliminazione $e'),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('SI'),
                                      ),
                                    ],
                                  ));
                        },
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )
          .toList();
      var app = new ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: oggetti.length,
        itemBuilder: (BuildContext context, int index) {
          return oggetti[index];
        },
      );

      List<Post> cose = await httpService.getPosts(idDispensa);
      if (cose.length > 0) {
        setState(() {
          oggetti2 = cose
              .map(
                (Post post) => _itemBuilder(post),
              )
              .toList();
        });
      } else {
        oggetti2 = [noElements];
      }
      setState(() {
        idDispensa = dispense[0].id;
        elencoDispense = app;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(nomeDispensa),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colori.primario,
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddTaskScreen())),
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
              (elencoDispense != null)
                  ? elencoDispense
                  : Center(child: CircularProgressIndicator()),
              SizedBox(height: 15),
              FloatingActionButton(
                  backgroundColor: Colori.primario,
                  child: Icon(Icons.add),
                  onPressed: () async {
                    pop.callback = caricaDispense;
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return pop.popupDispensa(context);
                        });
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          header: MaterialClassicHeader(color: Colori.primario),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("pull up load");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("release to load more");
              } else {
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: new ListView.builder(
            itemCount: oggetti2.length,
            itemBuilder: (BuildContext context, int index) {
              print(oggetti2[index]);
              return oggetti2[index];
            },
          ),
        ));
  }

  Widget _itemBuilder(Post post) {
    return Container(
      child: Stack(
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
          child: Container(child: PostTile(post: post)),
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
        style: TextStyle(
          fontSize: 14,
        ),
        overflow: TextOverflow.fade,
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
        http.Response res = await http.post(Uri.parse(postsURL),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            });
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
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                nameItem,
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
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
