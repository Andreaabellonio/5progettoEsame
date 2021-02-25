import 'package:flutter/material.dart';
import '../../app.dart';
import '../../models/location.dart';
import '../../widgets/image_banner.dart';
import './tile_overlay.dart';
import 'package:translator/translator.dart';

class Locations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {    
    final locations = Location.fetchAll();
    String variabile;
    traduci("Title").then((value) => variabile=value);
    return Scaffold(
        appBar: AppBar(
          title: Text(variabile),
        ),
        body: ListView.builder(
          //?crea una lista scrollable di widget
          itemCount: locations.length,
          itemBuilder: (context, index) => _itemBuilder(
              context, locations[index]), //?richiamo di funzione anonima
        ));
  }

  _onLocationTap(BuildContext context, int locationID) {
    Navigator.pushNamed(context, LocationDetailRoute,
        arguments: {"id": locationID});
  }

  Widget _itemBuilder(BuildContext context, Location location) {
    return GestureDetector(
      child: Container(
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            ImageBanner(assetPath: location.imagePath, height: 245.0),
            TileOverlay(location),
          ],
        ),
      ),
      onTap: () => _onLocationTap(context, location.id),
    );
  }
}

Future<String> traduci(String input) async{
  final translator = GoogleTranslator();  
  var translation = await translator.translate(input, to: 'it');
  return translation.toString();
}