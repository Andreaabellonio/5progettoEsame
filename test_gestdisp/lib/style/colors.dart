import 'package:flutter/material.dart';

class Colori{

static Color primario=Color.fromARGB(255, 250, 205, 137);
static Color grigioTenue=Color.fromARGB(255, 214, 224, 240);
static Color intermezzoGrigi=Color.fromARGB(255, 141, 147, 171);
static Color scuro=Color.fromARGB(255, 57, 59, 68);
static Color bianco=Color.fromARGB(255, 255, 255, 255);
static Color sfondo=Color.fromARGB(255, 254, 251, 245);
static Color grigioChiaro=Color.fromARGB(255, 230, 230, 230);

//colori sfondo

static Color mango=Color.fromARGB(255, 255, 190, 11);
static Color orangePantone=Color.fromARGB(255, 251, 86, 7);
static Color winterSky=Color.fromARGB(255, 255, 0, 110);
static Color blueViolet=Color.fromARGB(255, 131, 56, 236);
static Color azure=Color.fromARGB(255, 58, 134, 255);
static Color redPigment=Color.fromARGB(255, 248, 37, 41);
}

class ColoriDisp{

  Color colori;

  ColoriDisp({
    required this.colori,
  });

  static List<ColoriDisp> fetchAll(){
    return[
      ColoriDisp(colori:Color.fromARGB(255, 255, 190, 11)),
      ColoriDisp(colori:Color.fromARGB(255, 251, 86, 7)),
      ColoriDisp(colori:Color.fromARGB(255, 255, 0, 110)),
      ColoriDisp(colori:Color.fromARGB(255, 131, 56, 236)),
      ColoriDisp(colori:Color.fromARGB(255, 58, 134, 255)),
      ColoriDisp(colori:Color.fromARGB(255, 248, 37, 41)),
    ];
  }
}