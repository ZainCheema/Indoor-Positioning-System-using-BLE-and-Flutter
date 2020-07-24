import 'package:flutter/material.dart';
import 'Model/User.dart';
import 'UmbrellaBeaconTools/BeaconTools.dart';

class EddystoneUIDCard extends StatelessWidget {
  final EddystoneUID eddystoneUID;

  EddystoneUIDCard({@required this.eddystoneUID});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("EddystoneUID"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("beaconId: ${eddystoneUID.beaconId}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("namespaceId: ${eddystoneUID.namespaceId}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("tx: ${eddystoneUID.tx}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("rssi: ${eddystoneUID.rssi}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("distance: ${eddystoneUID.distance}"),
          ),
        ],
      ),
    );
  }
}

class SubtitleBar extends StatelessWidget {
  final String left;
  final String right;

  SubtitleBar({@required this.left, @required this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "user: " + left,
              style: subtitleTextStyle,
            ),
            Text(
              "Facing "+ right + " O' Clock",
              style: subtitleTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  final TextStyle subtitleTextStyle = TextStyle(fontSize: 17);
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
                  child: Text("w2")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "w2",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text('w2'),
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
        'Bluetooth adapter is ${message}',
        style: Theme.of(context).primaryTextTheme.subhead,
      ),
      trailing: new Icon(
        Icons.error,
        color: Theme.of(context).primaryTextTheme.subhead.color,
      ),
    ),
  );
}
