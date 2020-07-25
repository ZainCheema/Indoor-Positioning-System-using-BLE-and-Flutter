import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:umbrella/Model/AppStateModel.dart';
import 'package:umbrella/Model/BeaconInfo.dart';
import 'package:umbrella/widgets.dart';
import '../styles.dart';

bool isBroadcasting = false;

AppStateModel appStateModel = AppStateModel.instance;
String phoneMake = "";
BeaconInfo bc;

class OpeningScreen extends StatefulWidget {
  @override
  OpeningScreenState createState() {
    return OpeningScreenState();
  }
}

class OpeningScreenState extends State<OpeningScreen> {
  @override
  void initState() {
    super.initState();
    print("Showing Opening Screen");

    bc = new BeaconInfo(
        phoneMake: phoneMake,
        beaconUUID: "",
        txPower: "-59",
        standardBroadcasting: "Eddystone");

    getBeaconInfo();
  }

  getBeaconInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      phoneMake = androidInfo.model.toString();

      bc = new BeaconInfo(
          phoneMake: phoneMake,
          beaconUUID: appStateModel.user.uuid,
          txPower: "-59",
          standardBroadcasting: "Eddystone");
    });
  }

  buildScanButton() {
    if (isBroadcasting) {
      return new FloatingActionButton(
        child: new Icon(Icons.stop),
        backgroundColor: Colors.red,
        onPressed: stopBeaconBroadcast(),
      );
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.record_voice_over),
          backgroundColor: Colors.lightGreen,
          onPressed: startBeaconBroadcast());
    }
  }

  startBeaconBroadcast() {}

  stopBeaconBroadcast() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: createMaterialColor(Color(0xFFE8E6D9)),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Umbrella',
              style: TextStyle(color: Colors.black),
            ),
            const Image(image: AssetImage('assets/icons8-umbrella-24.png'))
          ],
        ),
      ),
      floatingActionButton: buildScanButton(),
      body: new Stack(children: <Widget>[
        Center(child: BeaconInfoContainer(beaconInfo: bc))
      ]),
    );
  }
}
