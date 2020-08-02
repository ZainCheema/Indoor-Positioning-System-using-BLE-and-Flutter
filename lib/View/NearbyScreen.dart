import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:umbrella/Model/AppStateModel.dart';
import 'package:umbrella/Model/BeaconInfo.dart';
import 'package:umbrella/Model/RangedBeaconData.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:umbrella/widgets.dart';
import 'package:umbrella/UmbrellaBeaconTools/UmbrellaBeacon.dart';
import 'package:wakelock/wakelock.dart';
import 'package:umbrella/UmbrellaBeaconTools/LocalizationAlgorithms.dart';
import '../styles.dart';

String beaconStatusMessage;
AppStateModel appStateModel = AppStateModel.instance;

Localization localization = new Localization();

Map<String, double> wtCoordinates;
Map<String, double> minMaxCoordinates;

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
  StreamSubscription beaconSubscription;
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
          appStateModel.isScanning = false;
          appStateModel.wifiEnabled = false;
          stopScan();
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
    beaconSubscription?.cancel();
    beaconSubscription = null;
    super.dispose();
  }

  startScan() {
    print("Scanning now");

    if (bleManager == null || umbrellaBeacon == null) {
      print('BleManager is null!');
    } else {
      appStateModel.isScanning = true;
    }

    beaconSubscription = umbrellaBeacon.scan(bleManager).listen((beacon) {
      setState(() {
        beacons[beacon.hash] = beacon;
      });
    }, onDone: stopScan);
  }

  stopScan() {
    print("Scan stopped");
    beaconSubscription?.cancel();
    beaconSubscription = null;
    setState(() {
      appStateModel.isScanning = false;
    });
  }

  buildRangedBeaconTiles() {
    List<BeaconInfo> anchorBeacons = AppStateModel.instance.getAnchorBeacons();

    return beacons.values.map<Widget>((b) {
      if (b is EddystoneUID) {
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

              wtCoordinates = localization.WeightedTrilaterationPosition();
              appStateModel.addWTXY(wtCoordinates);

              minMaxCoordinates = localization.MinMaxPosition();
              appStateModel.addMinMaxXY(minMaxCoordinates);
            }

            new Timer(const Duration(seconds: 1),
                () => appStateModel.uploadRangedBeaconData(rbd, pBeacon.phoneMake + "+" + pBeacon.beaconUUID));

            return RangedBeaconCard(beacon: rbd);
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
          backgroundColor: Colors.redAccent,
          onPressed: () {
            stopScan();
            setState(() {
              appStateModel.isScanning = false;
            });
          });
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.search),
          backgroundColor: Colors.greenAccent,
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

    tiles.addAll(buildRangedBeaconTiles());

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
          (rangedAnchorBeacons.length < 3) ?
          buildInfoTitle(context, "You need " + (3 - rangedAnchorBeacons.length).toString() + " more anchor nodes for position estimate"):
          buildInfoTitle(context, "Estimated Trilateration position: " + wtCoordinates['x'].toStringAsFixed(4) + " , " + wtCoordinates['y'].toStringAsFixed(4)
          + "\n\nEstimated Min Max position: " + minMaxCoordinates['x'].toStringAsFixed(4) + " , " + minMaxCoordinates['y'].toStringAsFixed(4)),
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
