import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:flutter/material.dart';

class MobileVision extends StatefulWidget {

  Function(String) callback;
  MobileVision(this.callback);

  @override
  _MobileVisionState createState() => _MobileVisionState();
}

class _MobileVisionState extends State<MobileVision> {
  String _textsOcr;

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
      texts.add(OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;
    int i = 0;
    int f = 0;
    String testo = "";

    for (OcrText t in texts) {
      RegExpMatch exp = RegExp(
              "([0-1][0-9] [0-9]{4})|([0-1][0-9]-[0-9]{4})|([0-3][0-9]/[0-1][0-9]/[0-9]{4})|([0-3][0-9]\.[0-1][0-9]\.[0-9]{4})|([0-3][0-9]/[0-1][0-9]/[0-9]{2})|([0-3][0-9] [0-1][0-9] [0-9]{2,4})|([0-9]{2,4} [0-1][0-9] [0-3][0-9])")
          .firstMatch(t.value);
      if (exp != null) {
        testo = t.value;
        i = exp.start;
        f = exp.end;
      }
    }
     print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEGGEG");
    widget.callback(testo.substring(i, f));
  }

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((x) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return TextButton(onPressed: _read, child: Text("scegli data"));
  }
}
