import 'package:flutter/material.dart';
import 'Model/User.dart';
import 'UmbrellaBeaconTools/BeaconTools.dart';
import 'Model/Post.dart';

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

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(18.0),
        child: Container(
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(80.0)),
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(post.user.userName)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(post.postText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(post.user.distance.toString()),
                    Text("Facing " + post.user.facing.toString() + " O'Clock"),
                  ],
                ),
              ),
            ])));
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
                  child: Text(user.distance.toString())),
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
                child: Text(user.facing),
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
