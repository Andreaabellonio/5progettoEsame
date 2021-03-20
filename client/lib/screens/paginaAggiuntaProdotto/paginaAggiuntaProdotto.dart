import 'package:flutter/material.dart';

class PaginaAggiuntaProdotto extends StatefulWidget {
  String nomeProdotto;
  String urlImmagine;
  String calorie;
  String nutriScore;
  List<String> tracce;

  PaginaAggiuntaProdotto(this.nomeProdotto, this.urlImmagine, this.calorie,
      this.nutriScore, this.tracce);

  @override
  _PaginaAggiuntaProdottoState createState() => _PaginaAggiuntaProdottoState(
      nomeProdotto, urlImmagine, calorie, nutriScore, tracce);
}

class _PaginaAggiuntaProdottoState extends State<PaginaAggiuntaProdotto> {
  String nomeProdotto;
  String urlImmagine;
  String calorie;
  String nutriScore;
  List<String> tracce;
  _PaginaAggiuntaProdottoState(this.nomeProdotto, this.urlImmagine,
      this.calorie, this.nutriScore, this.tracce);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aggiungi Prodotto"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Container(
            child: Text(
              nomeProdotto,
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Container(
            child: Text(
              "NutriScore: " + nutriScore,
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Container(
            child: Text(
              "calorie: " + calorie,
              style: TextStyle(fontSize: 20),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Text("puo contenere tracce di:"),
          ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: tracce.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  child: Center(child: Text('${tracce[index]}')),
                );
              }),
          Image.network('$urlImmagine', fit: BoxFit.contain),
          
          TextButton(child:Text("aggiungi"),onPressed: () {
            //mando la chiamata
          },)


        ],
      ),
    );
  }
}
