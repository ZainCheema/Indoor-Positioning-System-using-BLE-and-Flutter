import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/internal/bridge/internal_bridge_lib.dart';
import 'UmbrellaBeaconTools/umbrella_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Umbrella Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Umbrella Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UmbrellaBeacon umbrellaBeacon = UmbrellaBeacon.instance;
FlutterBleLib _flutterBleLib = FlutterBleLib();

  @override
  Widget build(BuildContext context) {
    startBeaconBroadcast();

  }
}

   startBeaconBroadcast() async {
    BeaconBroadcast beaconBroadcast = BeaconBroadcast();

    var transmissionSupportStatus =
        await beaconBroadcast.checkTransmissionSupported();
    switch (transmissionSupportStatus) {
      case BeaconStatus.SUPPORTED:
        print("You're good to go, you can advertise as a beacon");

        // ! EDDYSTONE DOESNT HAVE MAJOR & MINOR VALUES! IBEACON DOES! HENCE THE NO WORKING!
        // ! https://www.beaconzone.co.uk/choosinguuidmajorminor
        // ! https://github.com/google/eddystone/issues/188

        beaconBroadcast
            .setUUID('8b0ca750-e7a7-4e14-bd99-095477cb3e77')
            .setMajorId(1)
            .setMinorId(100)
            .start();

        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
          print("Beacon is advertising");
        });

        break;
      case BeaconStatus.NOT_SUPPORTED_MIN_SDK:
        // Your Android system version is too low (min. is 21)
        break;
      case BeaconStatus.NOT_SUPPORTED_BLE:
        // Your device doesn't support BLE
        break;
      case BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER:
        // Either your chipset or driver is incompatible
        break;
    }
  }
