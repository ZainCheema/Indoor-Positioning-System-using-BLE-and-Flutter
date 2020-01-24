import 'package:flutter/material.dart';
import 'UmbrellaBeaconTools/beacon_tools.dart';

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
          Text("EddystoneUID"),
          Text("beaconId: ${eddystoneUID.beaconId}"),
          Text("namespaceId: ${eddystoneUID.namespaceId}"),
          Text("tx: ${eddystoneUID.tx}"),
          Text("rssi: ${eddystoneUID.rssi}"),
          Text("distance: ${eddystoneUID.distance}"),
        ],
      ),
    );
  }
}