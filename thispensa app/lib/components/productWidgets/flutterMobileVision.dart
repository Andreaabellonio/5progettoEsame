import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:flutter/material.dart';
import 'package:thispensa/styles/colors.dart';

class MobileVision extends StatefulWidget {
  Function(String) callback;
  MobileVision(this.callback);

  @override
  _MobileVisionState createState() => _MobileVisionState();
}

class _MobileVisionState extends State<MobileVision> {
  Future<Null> _read() async {
    print("sciao beo");
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        flash: false,
        autoFocus: true,
        multiple: true,
        waitTap: true,
        showText: true,
        preview: Size(1080, 1920),
        camera: 0,
        fps: 2.0,
      );
    } on Exception {
      texts.add(widget.callback(''));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Nessuna data riconosciuta'),
        ),
      );
    }

    if (!mounted) return;
    String testo = "";
    String app = "";

    //?L'obiettivo è formattare tutte i tipi di date to AAAA-MM-GG
    /*
    var listaReg = [
      "([0-1]*[0-9]) [0-9]{4}", //MM AAAA
      "([0-1]*[0-9])-[0-9]{4}", //MM-AAAA
      "(([0-9]|[0-3][0-9])\/([0-1][0-9])\/[0-9]{2,4})", //GG/MM/AAAA anche con AA
      "(([0-9]|[0-3][0-9])\.([0-1][0-9])\.[0-9]{4})", //GG.MM.AAAA
      "([0-3][0-9] ([0-1][0-9]) [0-9]{2,4})", //GG MM AAAA anche AA
      "([0-9]{2,4} ([0-1][0-9]) [0-3][0-9])" //AAAA MM GG anche AA
    ];
    */
    for (OcrText t in texts) {
      RegExpMatch exp =
          RegExp(r"(([0-9]|[0-3][0-9])\/([0-1][0-9])\/[0-9]{2,4})")
              .firstMatch(t.value);
      if (exp != null) {
        app = t.value.substring(exp.start, exp.end);
        testo = app.split('/')[2] +
            "-" +
            app.split('/')[1] +
            "-" +
            app.split('/')[0];
        break; //ottimizzazzione level 9000(questo Barbero non deve vederlo)
      }
      exp = RegExp(r"(([0-9]|[0-3][0-9])\.([0-1][0-9])\.[0-9]{4})")
          .firstMatch(t.value.toString());
      if (exp != null) {
        app = t.value.substring(exp.start, exp.end);
        testo = app.split('.')[2] +
            "-" +
            app.split('.')[1] +
            "-" +
            app.split('.')[0];
        break; //ottimizzazzione level 9000(questo Barbero non deve vederlo)
      }
      exp = RegExp(r"([0-3][0-9] ([0-1][0-9]) [0-9]{2,4})").firstMatch(t.value);
      if (exp != null) {
        app = t.value.substring(exp.start, exp.end);
        testo = app.split(' ')[2] +
            "-" +
            app.split(' ')[1] +
            "-" +
            app.split(' ')[0];
        break; //ottimizzazzione level 9000(questo Barbero non deve vederlo)
      }
      exp = RegExp(r"([0-9]{2,4} ([0-1][0-9]) [0-3][0-9])").firstMatch(t.value);
      if (exp != null) {
        app = t.value.substring(exp.start, exp.end);
        testo = app.replaceAll(' ', '-');
        break; //ottimizzazzione level 9000(questo Barbero non deve vederlo)
      }
      exp = RegExp(r"([0-1]*[0-9]) [0-9]{4}").firstMatch(t.value);
      if (exp != null) {
        app = t.value.substring(exp.start, exp.end);
        testo = app.split(' ')[1] +
            "-" +
            ((app.split(' ')[0].length == 1)
                ? "0" + app.split(' ')[0]
                : app.split(' ')[0]) +
            "-" +
            "01"; //metto il primo giorno del mese
        break; //ottimizzazzione level 9000(questo Barbero non deve vederlo)
      }
      exp = RegExp(r"([0-1]*[0-9])-[0-9]{4}").firstMatch(t.value);
      if (exp != null) {
        app = t.value.substring(exp.start, exp.end);
        testo = app.split('-')[1] +
            "-" +
            ((app.split(' ')[0].length == 1)
                ? "0" + app.split(' ')[0]
                : app.split(' ')[0]) +
            "-" +
            "01"; //metto il primo giorno del mese
        break; //ottimizzazzione level 9000(questo Barbero non deve vederlo)
      }
    }
    if (testo != "") widget.callback(testo);
  }

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((x) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        child: Center(
            child: Ink(
          decoration: const ShapeDecoration(
            color: Colori.primarioTenue,
            shape: CircleBorder(),
          ),
          child: IconButton(
            iconSize: 40,
            onPressed: _read,
            icon: Icon(Icons.photo_camera),
          ),
        )),
      ),
    );
  }
}
