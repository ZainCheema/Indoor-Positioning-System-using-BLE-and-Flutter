import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umbrella/Model/AppStateModel.dart';
import 'package:umbrella/utils.dart';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:umbrella/Model/User.dart';
import 'package:umbrella/widgets.dart';
import 'package:umbrella/UmbrellaBeaconTools/UmbrellaBeacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

import '../styles.dart';

var firestoreReference = Firestore.instance;
String beaconStatusMessage;

class NearbyScreen extends StatefulWidget {
  @override
  NearbyScreenState createState() {
    return NearbyScreenState();
  }
}

class NearbyScreenState extends State<NearbyScreen> {
  UmbrellaBeacon umbrellaBeacon = UmbrellaBeacon.instance;

  BleManager bleManager = BleManager();

  // Scanning
  StreamSubscription _scanSubscription;
  Map<int, Beacon> beacons = new Map();
  bool isScanning = false;

  // State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();

    AppStateModel appStateModel = AppStateModel.instance;
    
    appStateModel.init();

    bleManager.createClient();

    // Subscribe to state changes
    _stateSubscription = bleManager.observeBluetoothState().listen((s) {
      setState(() {
        state = s;
        debugPrint("Bluetooth State changed");
        if (state == BluetoothState.POWERED_ON) {
          startBeaconBroadcast();
          _startScan();
        }
      });
    });
  }

  @override
  void dispose() {
    debugPrint("dispose() called");
    beacons.clear();
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    super.dispose();
  }

  _clearAllBeacons() {
    setState(() {
      beacons = Map<int, Beacon>();
    });
  }

  _startScan() {
    print("Scanning now");

    if (bleManager == null || umbrellaBeacon == null) {
      print('BleManager is null!!!');
    }

    _scanSubscription = umbrellaBeacon.scan(bleManager).listen((beacon) {
      setState(() {
        beacons[beacon.hash] = beacon;
      });
    }, onDone: _stopScan);

    setState(() {
      isScanning = true;
    });
  }

  _stopScan() {
    print("Scan stopped");
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      isScanning = false;
    });
  }

  _buildScanResultTiles() {
    print("_buildScanResultTiles() entered");
    List<User> allUsers = AppStateModel.instance.getAllUsers();
    debugPrint("All Users: " + allUsers.length.toString());
    List<User> nearbyUsers = new List<User>();

      return beacons.values.map<Widget>((b) {
        if (b is EddystoneUID) {
          for (var pUser in allUsers) {
            if (pUser.uuid == b.namespaceId) {
              debugPrint("User " + pUser.userName + " is nearby!");
              nearbyUsers.add(pUser);
              return UserCard(user: pUser);
            }
          }
          return EddystoneUIDCard(eddystoneUID: b);
        }
        return Card();
      }).toList();
  }

  _buildProgressBarTile() {
    return new LinearProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    var tiles = new List<Widget>();

    tiles.add(buildAlertTile(context, beaconStatusMessage));

    if (state != BluetoothState.POWERED_ON) {
      tiles.add(buildAlertTile(context, state.toString().substring(15)));
    }

    tiles.addAll(_buildScanResultTiles());

    tiles = _buildScanResultTiles();

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
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          (isScanning) ? _buildProgressBarTile() : new Container(),
          Expanded(
            child: new ListView(
              children: tiles,
            ),
          )
        ],
      ),
    );
  }
}

startBeaconBroadcast() async {
  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  var transmissionSupportStatus =
      await beaconBroadcast.checkTransmissionSupported();
  switch (transmissionSupportStatus) {
    case BeaconStatus.SUPPORTED:
      print("Beacon advertising is supported on this device");

      // ! EDDYSTONE DOESNT HAVE MAJOR & MINOR VALUES! IBEACON DOES! HENCE THE NO WORKING!
      // ! https://www.beaconzone.co.uk/choosinguuidmajorminor
      // ! https://github.com/google/eddystone/issues/188

      if (Platform.isAndroid) {
        //! Note: BeaconBroadcast doesnt have specific Eddystone methods,
        //! so setMajorId() is actually setting the beaconID.
        //! only the first 20 chars of the uuid will be used for its NamespaceID, the rest is discarded.

        // TODO: (Low Priority) Rename BroadcastBeacon methods to make more sense for a specific platform
        beaconBroadcast
            .setUUID(AppStateModel.instance.getUser().uuid)
            .setMajorId(randomNumber(1, 99))
            .setMinorId(100)
            .start();
      }

      beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
        beaconStatusMessage = "Beacon is now advertising";
        print(beaconStatusMessage);
      });
      break;
    case BeaconStatus.NOT_SUPPORTED_MIN_SDK:
      beaconStatusMessage =
          "Your Android system version is too low (min. is 21)";
        print(beaconStatusMessage);
      break;
    case BeaconStatus.NOT_SUPPORTED_BLE:
      beaconStatusMessage = "Your device doesn't support BLE";
      print(beaconStatusMessage);
      break;
    case BeaconStatus.NOT_SUPPORTED_CANNOT_GET_ADVERTISER:
      beaconStatusMessage = "Either your chipset or driver is incompatible";
      print(beaconStatusMessage);
      break;
  }
}
