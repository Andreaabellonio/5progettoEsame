import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/location.dart';
import 'text_section.dart';
import '../../widgets/image_banner.dart';
import '../../models/location.dart';
import '../../widgets/location_tile.dart';

class LocationDetail extends StatelessWidget {
  final int _locationID;
  LocationDetail(this._locationID);
  @override
  Widget build(BuildContext context) {
    final location = Location.fetchByID(_locationID);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(location.name),
        ),
        body: SingleChildScrollView(
            //?crea una vista scrollable con un solo child
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImageBanner(assetPath: location.imagePath),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
              child: LocationTile(location: location),
            ),
          ]..addAll(textSections(
              location)), //tipo foreach, appendendo gli oggetti creati da textSections
        )));
  }

  List<Widget> textSections(Location location) {
    return location.facts
        .map((fact) => TextSection(fact.title, fact.text))
        .toList();
  }
}
