import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import '../object_list/post_model.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class HttpService {
  final String postsURL = "https://thispensa.herokuapp.com/leggiDispensa";

  Future<List<Post>> getPosts() async {
    var params = {
      "idDispensa": "default",
      "uid": _auth.currentUser.uid.toString(),
      "tokenJWT": await _auth.currentUser.getIdToken()
    };
    //? Richiesta post al server node con parametri
    Response res = await post(Uri.parse(postsURL),
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
      List<Post> posts = new List<Post>();

      for (var i = 0; i < lista.length; i++) {
        String nome = await getProduct1(lista[i]["idProdotto"]);
        posts.add(Post(
            barcode: lista[i]["idProdotto"] as String,
            name: nome,
            qta: lista[i]["qta"] as int,
            dataScadenza: DateTime.parse(lista[i]["dataScadenza"])));
      }

      return posts;
    } else {
      throw "Unable to retrieve posts.";
    }
  }

  Future<Post> nonloso(Map<String, dynamic> json) async {
    String nome;

    await getProduct1(json["idProdotto"]);

    return Post(
        barcode: json['idProdotto'] as String,
        name: nome,
        qta: json['qta'] as int);
  }
}

Future<String> getProduct1(barcode) async {
  ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
      language: OpenFoodFactsLanguage.ITALIAN, fields: [ProductField.ALL]);
  ProductResult result = await OpenFoodAPIClient.getProduct(configuration);

  if (result.status == 1) {
    String nome = result.product.productName;
    return nome;
  }
  return "error";
}
