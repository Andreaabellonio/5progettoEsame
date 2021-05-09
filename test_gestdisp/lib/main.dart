import 'package:flutter/material.dart';
import 'package:test_gestdisp/style/colors.dart';
import 'object_list/list.dart';
import 'package:numberpicker/numberpicker.dart';

import '../style/colors.dart';
import 'dart:math';
import 'screen/specs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colori.primario,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}




class _MyHomePageState extends State<MyHomePage> {
  final List<Location> list = Location.fetchAll();

  var rng = new Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colori.sfondo,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(),
        ),
      ),
      body: ListView.builder(
        //?crea una lista scrollable di widget
        itemCount: list.length,
        itemBuilder: (context, index) => _itemBuilder(context, list[index],
            Colori.grigioChiaro, index), //?richiamo di funzione anonima
      ),
    );
  }

  /*_onLocationTap(BuildContext context, int locationID) {
    Navigator.pushNamed(context, LocationDetailRoute,
        arguments: {"id": locationID});
  }*/

  Widget _itemBuilder(BuildContext context, Location location, Color colore, int index) {
    return GestureDetector(
        child: Container(
          child: Stack(
            //alignment: AlignmentDirectional.bottomEnd,
            children: [
              TileOverlay(location, colore, index),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Specs(location)),
          );
        });
  }
}

class TileOverlay extends StatelessWidget {
  final Location location;
  final Color colore;
  final int index;
  TileOverlay(this.location, this.colore, this.index);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
            //padding: EdgeInsets.symmetric(vertical: 5.0),
            /*decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5)), //opacità tra 0 e 1*/
            child: LocationTile(location: location, colore: colore, index: index))
      ],
    );
  }
}

class LocationTile extends StatefulWidget {
  LocationTile({required this.location, required this.colore, required this.index});

  final Location location;
  final Color colore;
  final int index;
  @override
  _LocationTileState createState() =>
      new _LocationTileState(location: location, colore: colore, index: index);
}

//----------------------------------------------------------------------------------------//

class _LocationTileState extends State<LocationTile> {
  _LocationTileState({required this.location, required this.colore, required this.index}); //!default value, parametri tra {} vuol dire che sono opzionali
  final Location location;
  final Color colore;
  final int index;

  @override
  Widget build(BuildContext context) {
    //costruzione item dove inserire il NOME del prodotto
    final nameItem = Container(
      width: 150,
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(left: 12.0),
      child: Text(
        location.name.toUpperCase(),
        //style: Theme.of(context).textTheme.bodyText1,
        style: TextStyle(
          fontSize: 14,
        ),
        overflow: TextOverflow.fade,
        //textAlign: TextAlign.justify,
      ),
    );

    final numberPicker = NumberPicker(
      textStyle: TextStyle(fontSize: 12),
      value: location.qta,
      minValue: 0,
      maxValue: 100,
      step: 1,
      itemHeight: 50,
      itemWidth: 50,
      axis: Axis.horizontal,
      onChanged: (value) => setState(() => location.qta = value),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black26),
      ),
    );

    final List<Location> list = Location.fetchAll();

    final trash = IconButton(
      alignment: Alignment.centerRight,
      icon: Icon(Icons.delete),
      color: Colori.scuro,
      iconSize: 35,
      onPressed: () => list.remove(location),
    );

    return Column(
      children: [
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          decoration: BoxDecoration(
            color: colore,
            borderRadius: BorderRadius.circular(10),
            //border: Border.all(color: Colors.black26),
          ),
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //SizedBox(height: 16)

                    nameItem,
                    

                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        //mainAxisAlignment: MainAxisAlignment.value(),
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



