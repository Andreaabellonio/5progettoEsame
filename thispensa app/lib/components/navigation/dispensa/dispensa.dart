import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thispensa/components/login/popupDispensa/popupDispensa.dart';
import 'package:thispensa/components/navigation/dispensa/paginaAggiuntaProdotto.dart';
import 'package:thispensa/models/dispensa_model.dart';
import 'package:thispensa/models/post_model.dart';
import '../../../styles/colors.dart';
import 'package:numberpicker/numberpicker.dart';
import 'chiamateServer/http_service.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyDispensa extends StatefulWidget {
  @override
  MyDispensaState createState() => MyDispensaState();
}

class MyDispensaState extends State<MyDispensa> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  final HttpService httpService = HttpService();
  String idDispensa;
  String creatoreDispensa;
  TextEditingController nomeDispensa = TextEditingController();
  //carico dinamicamente il nome della dispensa selezionata
  ListView elencoDispense;
  List<Post> oggetti2 = [];
  PopUpClass pop = new PopUpClass();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  List<Post> cose;

  Widget noElements = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Center(
          child: Text(
        "Ancora nessun prodotto presente!",
        style: TextStyle(fontSize: FontSize.xLarge.size),
      )));

  void onRefresh() async {
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.foldingCube;
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show();
    pop.first = false;
    setState(() {
      oggetti2 = []; //CHI TOCCA MUORE: senza questa schifezza non va nulla
    });
    await caricaDispense();
    if (mounted) {
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          refreshController.refreshCompleted();
        });
      });
    }
    EasyLoading.dismiss();
  }

  void _onLoading() async {
    if (mounted) {
      caricaDispense();
      refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
    pop.callback = onRefresh;
    nomeDispensa.text = "";
    onRefresh();

  }

  Future<void> caricaDispense() async {
    try {
      List<Dispensa> dispense = await httpService.getDispense();
      if (dispense.length == 0) {
        pop.first = true;
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return pop.popupDispensa(context);
            });
        onRefresh(); //ricarico gli elementi dopo che ha inserito una nuova dispensa
        pop.first = false;
      } else {
        pop.first = false;

        Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        nomeDispensa.text = prefs.getString("nomeDispensa");
        idDispensa = prefs.getString("idDispensa");
        creatoreDispensa = prefs.getString("creatoreDispensa");
        if (nomeDispensa.text == null || idDispensa == null) {
          nomeDispensa.text = dispense[0].nome;
          idDispensa = dispense[0].id;
        }

        List<Widget> oggetti = dispense
            .map(
              (Dispensa dispensa) => (_auth.currentUser.uid ==
                      dispensa.creatore)
                  ? Slidable(
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
                            prefs.setString(
                                "creatoreDispensa", dispensa.creatore);
                            List<Post> cose =
                                await httpService.getPosts(dispensa.id);
                            if (cose.length > 0) {
                              setState(() {
                                oggetti2 = cose;
                              });
                            } else {
                              oggetti2 = [];
                            }
                            setState(() {
                              nomeDispensa.text = dispensa.nome;
                              idDispensa = dispensa.id;
                            });
                            Navigator.pop(context);
                            EasyLoading.dismiss();
                          }),
                      actions: <Widget>[
                        IconSlideAction(
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
                                                    "Accept":
                                                        "application/json",
                                                    HttpHeaders
                                                            .contentTypeHeader:
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
                                                  prefs.remove("idDispensa");
                                                  onRefresh();
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
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
                        ),
                        IconSlideAction(
                          caption: 'Condividi',
                          color: Colors.indigo,
                          icon: Icons.share,
                          onTap: () async {
                            var params = {
                              "uid": _auth.currentUser.uid.toString(),
                              "tokenJWT": await _auth.currentUser.getIdToken()
                            };
                            http.post(
                                Uri.https('thispensa.herokuapp.com',
                                    '/modificaCondivisioneDispensa'),
                                body: json.encode(params),
                                headers: {
                                  "Accept": "application/json",
                                  "withCredential": "true",
                                  HttpHeaders.contentTypeHeader:
                                      "application/json"
                                }).then((response) async {
                              Map data = jsonDecode(response.body);
                              if (!data["errore"]) {
                              } else {}
                            });
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: QrImage(
                                        data: dispensa.id,
                                        version: QrVersions.auto,
                                        size: 320),
                                  );
                                });
                          },
                        ),
                      ],
                    )
                  : ListTile(
                      leading: Icon(Icons.text_snippet),
                      title: Text(dispensa.nome),
                      onTap: () async {
                        EasyLoading.instance.indicatorType =
                            EasyLoadingIndicatorType.foldingCube;
                        EasyLoading.instance.userInteractions = false;
                        EasyLoading.show();
                        prefs.setString("idDispensa", dispensa.id);
                        prefs.setString("nomeDispensa", dispensa.nome);
                        prefs.setString("creatoreDispensa", dispensa.creatore);
                        cose = await httpService.getPosts(dispensa.id);
                        if (cose.length > 0) {
                          setState(() {
                            oggetti2 = cose;
                          });
                        } else {
                          oggetti2 = [];
                        }
                        setState(() {
                          nomeDispensa.text = dispensa.nome;
                          idDispensa = dispensa.id;
                        });
                        Navigator.pop(context);
                        EasyLoading.dismiss();
                      }),
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

        cose = await httpService.getPosts(idDispensa);
        if (cose.length > 0) {
          setState(() {
            oggetti2 = cose;
          });
        } else {
          oggetti2 = [];
        }
        setState(() {
          idDispensa = dispense[0].id;
          elencoDispense = app;
        });
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Errore nel caricamento dei prodotti, riprovare'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: _isSearching
              ? const BackButton()
              : (Builder(
                  builder: (context) => IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(Icons.menu)))),
          title: _isSearching
              ? _buildSearchField()
              : TextField(
                  enabled: (_auth.currentUser.uid == creatoreDispensa),
                  controller: nomeDispensa,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  onSubmitted: (String valore) async {
                    EasyLoading.instance.indicatorType =
                        EasyLoadingIndicatorType.foldingCube;
                    EasyLoading.instance.userInteractions = false;
                    EasyLoading.show();
                    Future<SharedPreferences> _prefs =
                        SharedPreferences.getInstance();
                    final SharedPreferences prefs = await _prefs;
                    var params = {
                      "nomeDispensa": nomeDispensa.text,
                      "idDispensa": prefs.getString("idDispensa"),
                      "uid": _auth.currentUser.uid.toString(),
                      "tokenJWT": await _auth.currentUser.getIdToken(),
                    };
                    http.Response res = await http.post(
                        Uri.https(
                            'thispensa.herokuapp.com', '/aggiornaDispensa'),
                        body: json.encode(params),
                        headers: {
                          "Accept": "application/json",
                          HttpHeaders.contentTypeHeader: "application/json"
                        });
                    if (res.statusCode == 200) {
                      Map data = jsonDecode(res.body);
                      if (!data["errore"]) {
                        prefs.setString("nomeDispensa", valore);
                        onRefresh();
                        EasyLoading.dismiss();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Nome aggiornato con successo!"),
                          ),
                        );
                      } else {
                        EasyLoading.dismiss();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Errore durante l'aggiornamento!"),
                          ),
                        );
                      }
                    } else {
                      throw "Unable change pantry nome.";
                    }
                  },
                ),
          actions: _buildActions(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colori.primario,
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PaginaAggiuntaProdotto(
                      nomeProdotto: "",
                      barcode: "",
                      urlImmagine: "",
                      nutriScore: "Non disponibile per questo prodotto",
                      calorie: "",
                      tracce: ["Non disponibile per questo prodotto"],
                      refresh: onRefresh))),
        ),
        drawer: Container(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Drawer(
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
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            itemCount: oggetti2.length,
            itemBuilder: (BuildContext context, int index) {
              return _itemBuilder(oggetti2[index]);
            },
          ),
        ));
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    List<Post> coseFiltrate = cose
        .where((Post post) =>
            post.name.toLowerCase().contains(newQuery.toLowerCase()))
        .toList();
    setState(() {
      oggetti2 = coseFiltrate;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  Widget _itemBuilder(Post post) {
    return Container(
      child: Stack(
        children: [
          TileOverlay(post, onRefresh),
        ],
      ),
    );
  }
}

class TileOverlay extends StatelessWidget {
  final Post post;
  final callback;
  TileOverlay(this.post, void this.callback);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(child: PostTile(post: post, refresh: this.callback)),
        )
      ],
    );
  }
}

class PostTile extends StatefulWidget {
  final Post post;
  final _callback;
  const PostTile({Key key, this.post, void refresh()}) : _callback = refresh;
  @override
  _PostTileState createState() => new _PostTileState();
}

//----------------------------------------------------------------------------------------//

class _PostTileState extends State<PostTile> {
  final String postsURL =
      "https://thispensa.herokuapp.com/aggiornaProdottoDispensa";
  TextEditingController controllerNome = TextEditingController();

  FocusNode focus;
  @override
  void initState() {
    super.initState();
    focus = FocusNode();
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  Future<void> aggiornaNomeProdotto(String nome) async {
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.foldingCube;
    EasyLoading.instance.userInteractions = false;
    EasyLoading.show();
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var params = {
      "idProdotto": widget.post.idProdotto,
      "qta": widget.post.qta,
      "nome": nome,
      "idDispensa": prefs.getString("idDispensa"),
      "uid": _auth.currentUser.uid.toString(),
      "tokenJWT": await _auth.currentUser.getIdToken(),
    };
    http.Response res = await http.post(
        Uri.https('thispensa.herokuapp.com', '/aggiornaProdottoDispensa'),
        body: json.encode(params),
        headers: {
          "Accept": "application/json",
          HttpHeaders.contentTypeHeader: "application/json"
        });
    if (res.statusCode == 200) {
      Map data = jsonDecode(res.body);
      if (!data["errore"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nome aggiornato con successo!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Errore durante l'aggiornamento!"),
          ),
        );
      }
    } else {
      throw "Unable change product nome.";
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    controllerNome.text = widget.post.name;
    //costruzione item dove inserire il NOME del prodotto
    final nameItem = SizedBox(
        width: MediaQuery.of(context).size.width - 200,
        child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                Container(
                  height: 40,
                  child: TextField(
                    focusNode: focus,
                    enabled: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    controller: controllerNome,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    // overflow: TextOverflow.fade,
                    onSubmitted: (value) {
                      aggiornaNomeProdotto(controllerNome.text);
                    },
                  ),
                ),
                Container(
                  height: 40,
                  color: Colors.transparent,
                  child: GestureDetector(
                    onLongPress: () {
                      focus.requestFocus();
                    },
                    onTap: () {
                      //TODO APRIRE PAGINA PRODOTTO
                    },
                  ),
                ),
              ],
            )));
    final numberPicker = NumberPicker(
      textStyle: TextStyle(fontSize: 12),
      value: widget.post.qta,
      minValue: 1,
      maxValue: 100,
      step: 1,
      itemHeight: 50,
      itemWidth: 50,
      axis: Axis.horizontal,
      onChanged: (value) async {
        EasyLoading.instance.indicatorType =
            EasyLoadingIndicatorType.foldingCube;
        EasyLoading.instance.userInteractions = false;
        EasyLoading.show();
        Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        setState(() => widget.post.qta = value);
        var params = {
          "uid": _auth.currentUser.uid.toString(),
          "tokenJWT": await _auth.currentUser.getIdToken(),
          "idProdotto": widget.post.idProdotto,
          "qta": widget.post.qta,
          "nome": widget.post.name,
          "idDispensa": prefs.getString("idDispensa")
        };
        http.Response res = await http.post(
            Uri.https('thispensa.herokuapp.com', '/aggiornaProdottoDispensa'),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            });
        if (res.statusCode == 200) {
          Map data = jsonDecode(res.body);
          if (!data["errore"]) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Quantità aggiornata con successo!'),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text("Errore durante l'aggiornamento!"),
              ),
            );
          }
        }
        EasyLoading.dismiss();
      },
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
        EasyLoading.instance.indicatorType =
            EasyLoadingIndicatorType.foldingCube;
        EasyLoading.instance.userInteractions = false;
        EasyLoading.show();
        Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
        final SharedPreferences prefs = await _prefs;
        var params = {
          "idProdotto": widget.post.idProdotto,
          "barcode": widget.post.barcode,
          "idDispensa": prefs.getString("idDispensa"),
          "uid": _auth.currentUser.uid.toString(),
          "tokenJWT": await _auth.currentUser.getIdToken(),
        };
        http.Response res = await http.post(
            Uri.https('thispensa.herokuapp.com', '/eliminaProdottoDispensa'),
            body: json.encode(params),
            headers: {
              "Accept": "application/json",
              HttpHeaders.contentTypeHeader: "application/json"
            });
        if (res.statusCode == 200) {
          Map data = jsonDecode(res.body);
          if (!data["errore"]) {
            widget._callback();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Prodotto eliminato con successo'),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text("Errore durante l'eliminazione!"),
              ),
            );
          }
        } else {
          throw "Unable to retrieve posts.";
        }
        EasyLoading.dismiss();
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
