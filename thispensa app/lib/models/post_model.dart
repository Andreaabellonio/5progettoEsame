import 'package:flutter/foundation.dart';

class Post {
  String idProdotto;
  String barcode;
  String name;
  int qta;
  DateTime dataScadenza;

  Post(
      {@required this.idProdotto,
      @required this.barcode,
      @required this.name,
      @required this.qta,
      this.dataScadenza});
}
