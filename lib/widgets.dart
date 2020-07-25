import 'package:flutter/material.dart';
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

class UserCard extends StatelessWidget {
  final User user;

  UserCard({@required this.user});

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
                  child: Text(user.uuid)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.userName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(user.distance.toString() + "m"),
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


  buildProgressBarTile() {
    return new LinearProgressIndicator();
  }
