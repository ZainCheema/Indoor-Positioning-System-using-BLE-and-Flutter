import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:umbrella/Model/RangedBeaconInfo.dart';
import 'Model/User.dart';
import 'Model/BeaconInfo.dart';

class BeaconInfoContainer extends StatelessWidget {
  final BeaconInfo beaconInfo;

  BeaconInfoContainer({@required this.beaconInfo});

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(beaconInfo.phoneMake, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("beaconId: ${beaconInfo.beaconUUID}"),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("tx: ${beaconInfo.txPower}"),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("broadcast standard: ${beaconInfo.standardBroadcasting}"),
            ),
          ],
        ),
      ),
    );
  }
}

class RangedBeaconCard extends StatelessWidget {
  final BeaconInfo beacon;

  RangedBeaconCard({@required this.beacon});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(18.0),
        child: Container(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.topRight,
                  child: Text(beacon.beaconUUID)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  beacon.phoneMake,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text("DISTANCE HERE"),
              ),
            )
          ],
        )));
  }
}

buildAlertTile(BuildContext context, String message) {
  return new Container(
    color: Colors.redAccent,
    child: new ListTile(
      title: new Text(
        message,
        style: Theme.of(context).primaryTextTheme.subhead,
      ),
      trailing: new Icon(
        Icons.error,
        color: Theme.of(context).primaryTextTheme.subhead.color,
      ),
    ),
  );
}

showGenericDialog(BuildContext context, String title, String body) {
        if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content:
                    Text(body),
                actions: <Widget>[
                  FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ],
              );
            });
      }
}

  showGPSDialog(BuildContext context) async {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get current location"),
                content:
                    const Text('Please enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ],
              );
            });
      }
  }


  buildProgressBarTile() {
    return new LinearProgressIndicator();
  }
