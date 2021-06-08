import 'package:flutter/material.dart';
import 'dart:async';
import 'package:package_info/package_info.dart';

import '../stgButton.dart';

class InfoState extends State<Info> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle, {TextStyle style}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListTile(
        title: Center(
          child: Text(
            title,
            style: style,
          ),
        ),
        subtitle: Center(
            child: Text(
          subtitle.isNotEmpty ? subtitle : 'Not set',
          style: style,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Informazioni"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 35),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.memory, size: 110),
                      _infoTile('App version', _packageInfo.version,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 23)),
                    ],
                  ),
                ),
                _infoTile('App name', _packageInfo.appName),
                _infoTile('Package name', _packageInfo.packageName),
                _infoTile('Build number', _packageInfo.buildNumber),
              ],
            ),
          ),
        ));
  }
}
