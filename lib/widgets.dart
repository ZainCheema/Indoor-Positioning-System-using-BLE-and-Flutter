import 'dart:io';

import 'package:flutter/material.dart';
import 'UmbrellaBeaconTools/beacon_tools.dart';
import 'Model/PostModel.dart';

class IBeaconCard extends StatelessWidget {
  final IBeacon iBeacon;

  IBeaconCard({@required this.iBeacon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("iBeacon"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("uuid: ${iBeacon.uuid}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("major: ${iBeacon.major}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("minor: ${iBeacon.minor}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("tx: ${iBeacon.tx}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("rssi: ${iBeacon.rssi}"),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("distance: ${iBeacon.distance}"),
          ),
        ],
      ),
    );
  }
}

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

class PostCard extends StatelessWidget {

  final Post post;

  PostCard({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(18.0),
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(80.0)
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(post.userName)
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(post.postText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                    )
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(post.distance.toString()),
                  Text(post.angleFacing.toString()),
                ],
              ),
            ),
          ]
        )
      )
    );
  }



}