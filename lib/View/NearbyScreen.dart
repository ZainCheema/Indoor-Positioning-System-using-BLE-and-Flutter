import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:umbrella/Model/AppStateModel.dart';
import 'package:umbrella/Model/BeaconInfo.dart';
import 'package:umbrella/Model/RangedBeaconData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:umbrella/widgets.dart';
import 'package:umbrella/UmbrellaBeaconTools/UmbrellaBeacon.dart';
import 'package:wakelock/wakelock.dart';
import 'package:umbrella/UmbrellaBeaconTools/LocalizationAlgorithms.dart';

import '../styles.dart';
import '../utils.dart';

String beaconStatusMessage;
AppStateModel appStateModel = AppStateModel.instance;

Localization localization = new Localization();

//List<RangedBeaconData> rangedAnchorBeacons = new List<RangedBeaconData>()
Map<String, RangedBeaconData> rangedAnchorBeacons =
    new Map<String, RangedBeaconData>();

RangedBeaconData rbd;

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

  // ignore: cancel_subscriptions
  StreamSubscription networkChanges;
  var connectivityResult;

  // State
  StreamSubscription bluetoothChanges;
  BluetoothState blState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();

    //bleManager.setLogLevel(LogLevel.verbose);
    bleManager.createClient();

    // Subscribe to state changes
    bluetoothChanges = bleManager.observeBluetoothState().listen((s) {
      setState(() {
        blState = s;
        debugPrint("Bluetooth State changed");
        if (blState == BluetoothState.POWERED_ON) {
          appStateModel.bluetoothEnabled = true;
          debugPrint("Bluetooth is on");
        } else {
          appStateModel.bluetoothEnabled = false;
        }
      });
    });

    networkChanges = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectivityResult = result;
        if (connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile) {
          appStateModel.wifiEnabled = true;
          debugPrint("Network connected");
        } else {
          appStateModel.wifiEnabled = false;
        }
      });
    });

    Wakelock.enable();

    appStateModel.checkGPS();
  }

  @override
  void dispose() {
    debugPrint("dispose() called");
    beacons.clear();
    bluetoothChanges?.cancel();
    bluetoothChanges = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    super.dispose();
  }

  // _clearAllBeacons() {
  //   setState(() {
  //     beacons = Map<int, Beacon>();
  //   });
  // }

  startScan() {
    print("Scanning now");

    if (bleManager == null || umbrellaBeacon == null) {
      print('BleManager is null!');
    } else {
      appStateModel.isScanning = true;
    }

    _scanSubscription = umbrellaBeacon.scan(bleManager).listen((beacon) {
      setState(() {
        beacons[beacon.hash] = beacon;
      });
    }, onDone: stopScan);
  }

  stopScan() {
    print("Scan stopped");
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      appStateModel.isScanning = false;
    });
  }

  buildScanResultTiles() {
    List<BeaconInfo> anchorBeacons = AppStateModel.instance.getAnchorBeacons();

    return beacons.values.map<Widget>((b) {
      if (b is EddystoneUID) {
        //   debugPrint("EddyStone beacon nearby!");
        for (var pBeacon in anchorBeacons) {
          if (pBeacon.beaconUUID == b.namespaceId) {
            //beaconDebugInfo(pBeacon, b);

            // If beacon has already been added, update lists and upload to database
            // else, create a new RangedBeaconInfo obj and add that

            if (!rangedAnchorBeacons.containsKey(pBeacon.beaconUUID)) {
              rbd = new RangedBeaconData(
                  pBeacon.phoneMake, pBeacon.beaconUUID, b.tx);
              rbd.addRawRssi(b.rawRssi);
              rbd.addRawRssiDistance(b.rawRssiLogDistance);
              rbd.addkfRssi(b.kfRssi);
              rbd.addkfRssiDistance(b.kfRssiLogDistance);

              rbd.x = pBeacon.x;
              rbd.y = pBeacon.y;

              rangedAnchorBeacons[pBeacon.beaconUUID] = rbd;
            } else {
              rbd = rangedAnchorBeacons[pBeacon.beaconUUID];
              rbd.addRawRssi(b.rawRssi);
              rbd.addRawRssiDistance(b.rawRssiLogDistance);
              rbd.addkfRssi(b.kfRssi);
              rbd.addkfRssiDistance(b.kfRssiLogDistance);

              rangedAnchorBeacons[pBeacon.beaconUUID] = rbd;
            }

            Map<RangedBeaconData, double> rbdDistance = {
              rbd: b.kfRssiLogDistance
            };

            localization.addAnchorNode(rbd.beaconUUID, rbdDistance);
            if (localization.conditionsMet) {
              // print("Enough beacons for trilateration");
              var coordinates = localization.WeightedTrilaterationPosition();
              appStateModel.addWTXY(coordinates);
              coordinates = localization.MinMaxPosition();
              appStateModel.addMinMaxXY(coordinates);
            }

            String beaconName = pBeacon.phoneMake + "+" + pBeacon.beaconUUID;

            new Timer(const Duration(seconds: 1),
                () => appStateModel.uploadRangedBeaconData(rbd, beaconName));

                     return RangedBeaconCard(beacon: pBeacon);
          }
        }
      }
      return Card();
    }).toList();
  }

  buildScanButton() {
    if (appStateModel.isScanning) {
      return new FloatingActionButton(
          child: new Icon(Icons.stop),
          backgroundColor: Colors.red,
          onPressed: () {
            stopScan();
            setState(() {
              appStateModel.isScanning = false;
            });
          });
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.search),
          backgroundColor: Colors.lightGreen,
          onPressed: () {
            appStateModel.checkGPS();
            appStateModel.checkLocationPermission();
            if (appStateModel.wifiEnabled &
                appStateModel.bluetoothEnabled &
                appStateModel.gpsEnabled &
                appStateModel.gpsAllowed) {
              startScan();
              setState(() {
                appStateModel.isScanning = true;
              });
            } else if (!appStateModel.gpsAllowed) {
              showGenericDialog(context, "Location Permission Required",
                  "Location is needed to scan a beacon");
            } else {
              showGenericDialog(
                  context,
                  "Wi-Fi, Bluetooth and GPS need to be on",
                  'Please check each of these in order to scan');
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var tiles = new List<Widget>();

    tiles.addAll(buildScanResultTiles());

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
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          (connectivityResult == ConnectivityResult.none)
              ? buildAlertTile(context, "Wifi required to send beacon data")
              : new Container(),
          (appStateModel.isScanning) ? buildProgressBarTile() : new Container(),
          (blState != BluetoothState.POWERED_ON)
              ? buildAlertTile(context, "Please check that Bluetooth is on")
              : new Container(),
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
