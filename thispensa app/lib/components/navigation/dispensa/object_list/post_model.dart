import 'package:flutter/foundation.dart';

class Post {
  String barcode;
  String name;
  int qta;
  DateTime dataScadenza;

  Post(
      {@required this.barcode,
      @required this.name,
      @required this.qta,
      this.dataScadenza});

  /*factory Post.fromJson(Map<String, dynamic> json) async{
    String nome;

    await getProduct1(json["idProdotto"]);

    return Post(
        barcode: json['idProdotto'] as String,
        name: nome as String,
        qta: json['qta'] as int);
  }*/
}
