import 'package:Thispensa/components/navigation/dispensa/paginaAggiuntaProdotto.dart';
import 'package:Thispensa/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:translator/translator.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class Barcode extends StatefulWidget {
  Barcode({Key key}) : super(key: key);

  @override
  _BarcodeState createState() => _BarcodeState();
}

class _BarcodeState extends State<Barcode> {
  void _letturaDati(String codice) async {
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.foldingCube;
    EasyLoading.show();
    print("LETTURA DATI");
    print(codice);

    //funzione che prende il codice usa l'api che crea la scheda di aggiunta
    getProduct1(codice);
  }

  Future<void> getProduct1(barcode) async {
    try {
      ProductQueryConfiguration configuration = ProductQueryConfiguration(
          barcode,
          language: OpenFoodFactsLanguage.ITALIAN,
          fields: [ProductField.ALL]);
      ProductResult result = await OpenFoodAPIClient.getProduct(configuration);

      if (result.status == 1) {
        String nome =
            await traduci(result.product.productName, result.product.lang);
        String urlImg = result.product.imgSmallUrl == null
            ? "Non disponibile per questo prodotto"
            : result.product.imgSmallUrl;
        String calorie;
        try {
          calorie = result.product.nutriments.energyKcal.toString() == null
              ? "Non disponibile per questo prodotto"
              : result.product.nutriments.energyKcal.toString() +
                  " " +
                  result.product.nutriments.energyKcalUnit
                      .toString()
                      .split('.')[1];
        } catch (e) {
          calorie = "Non disponibile per questo prodotto";
        }
        String nutriScore = result.product.nutriscore == null
            ? "Non disponibile per questo prodotto"
            : result.product.nutriscore;
        List<String> tracce = result.product.allergens.ids == null
            ? "Non disponibile per questo prodotto"
            : result.product.allergens.ids;
        List<String> tracceTradotte = new List<String>();
        if (tracce.length > 0) {
          for (String allergen in tracce) {
            tracceTradotte.add(await traduci(
                allergen.split(':')[1], null, allergen.split(':')[0]));
          }
        } else
          tracceTradotte.add("Non disponibile per questo prodotto");
        String ingredienti = "";
        if (result.product.ingredientsTextEN != null)
          ingredienti = result.product.ingredientsTextEN == null
              ? "Non disponibile per questo prodotto"
              : await traduci(result.product.ingredientsTextEN, null, "en");
        else
          ingredienti = result.product.ingredientsText == ""
              ? "Non disponibile per questo prodotto"
              : await traduci(
                  result.product.ingredientsText, result.product.lang);
        String qta = result.product.quantity == null
            ? "Non disponibile per questo prodotto"
            : result.product.quantity.toString();
        EasyLoading.dismiss();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaginaAggiuntaProdotto(barcode, nome, urlImg,
                calorie, nutriScore, tracceTradotte),
          ),
        );
      } else {
        EasyLoading.dismiss();
        _showMyDialog(context, "Prodotto non trovato nel database");
      }
    } catch (e) {
      EasyLoading.dismiss();
      _showMyDialog(context, "Errore nella ricerca dei dati");
    }
  }

  //con [] indico i parametri opzionali
  Future<String> traduci(String input,
      [OpenFoodFactsLanguage language, String fromLang]) async {
    if (input != "" && input != null) {
      if (language != null) fromLang = rilevaLingua(language);
      if (fromLang != "it") {
        final translator = GoogleTranslator();
        var translation =
            await translator.translate(input, from: fromLang, to: 'it');
        return translation.toString();
      } else
        return input;
    } else
      return input;
  }

  Future<void> ScansionaBarCode() async {
    //? Funzione richiamata sul clic del pulsante
    String barcodeScanRes;
    RegExp exp = RegExp(r"(^[0-9]*$)"); //? regex per il controllo del barcode
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Esci", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Errore nello scanner di barcode';
    }
    if (!mounted) return;
    print(barcodeScanRes);
    if (barcodeScanRes != "-1") await _letturaDati(barcodeScanRes);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: ScansionaBarCode,
      child: Icon(Icons.add_a_photo),
      backgroundColor: Colori.primario,
    );
  }

  Future<void> _showMyDialog(BuildContext context, String testo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(testo)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

String rilevaLingua(OpenFoodFactsLanguage lang) {
  switch (lang) {
    case OpenFoodFactsLanguage.FRENCH:
      return "fr";
      break;
    case OpenFoodFactsLanguage.ENGLISH:
      return "en";
      break;
    case OpenFoodFactsLanguage.SPANISH:
      return "es";
      break;
    case OpenFoodFactsLanguage.ITALIAN:
      return "it";
      break;
    default:
      return "auto";
  }
}
