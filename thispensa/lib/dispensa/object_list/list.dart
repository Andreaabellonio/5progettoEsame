import 'package:flutter/material.dart';
import '../screen/specs.dart';


class Location {
  final int id;
  final String name;
  int qta;

  Location({
    this.id = 0,
    this.name = "",
    this.qta = 0,
  });

  static List<Location> fetchAll() {
    return [
      Location(
        id: 1,
        name: 'Kiyomizu-dera dadfa dafdaf daf',
        qta: 5,
      ),
      Location(
        id: 2,
        name: 'Mount Fuji',
        qta: 3,
      ),
      Location(
        id: 3,
        name: 'Arashiyama Bamboo Grove adfd adfad fdf adfadfzafda',
        qta: 1,
      ),
    ];
  }

  /*static Location fetchByID(int locationID) {
    List<Location> locations = Location.fetchAll();
    for (var i = 0; i < locations.length; i++) {
      if (locations[i].id == locationID) {
        return locations[i];
      }
      else 
    }
    return null;
  }*/


}
