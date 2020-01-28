import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'widgets.dart';
import 'UmbrellaBeaconTools/umbrella_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:uuid/uuid.dart';

final _random = new Random();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Umbrella Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.dark,
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

    bleManager.createClient();

    // Subscribe to state changes
    _stateSubscription = bleManager.observeBluetoothState().listen((s) {
      setState(() {
        state = s;
      });
    });

    startBeaconBroadcast();
  }

  @override
  void dispose() {
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

    if(bleManager == null || umbrellaBeacon == null) {
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

  _buildScanningButton() {
    if (state != BluetoothState.POWERED_ON) {
      return null;
    }
    if (isScanning) {
      return new FloatingActionButton(
        child: new Icon(Icons.stop),
        onPressed: _stopScan,
        backgroundColor: Colors.red,
      );
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.search), onPressed: _startScan);
    }
  }

  _buildScanResultTiles() {
    return beacons.values.map<Widget>((b) {
      if (b is IBeacon) {
        return IBeaconCard(iBeacon: b);
      }
      if (b is EddystoneUID) {
        return EddystoneUIDCard(eddystoneUID: b);
      }
      return Card();
    }).toList();
  }

  _buildAlertTile() {
    return new Container(
      color: Colors.redAccent,
      child: new ListTile(
        title: new Text(
          'Bluetooth adapter is ${state.toString().substring(15)}',
          style: Theme.of(context).primaryTextTheme.subhead,
        ),
        trailing: new Icon(
          Icons.error,
          color: Theme.of(context).primaryTextTheme.subhead.color,
        ),
      ),
    );
  }

  _buildProgressBarTile() {
    return new LinearProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    var tiles = new List<Widget>();
    if (state != BluetoothState.POWERED_ON) {
      tiles.add(_buildAlertTile());
    }

    tiles.addAll(_buildScanResultTiles());

    return new MaterialApp(
      theme: ThemeData.dark(),
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Umbrella Beacon Example'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: _clearAllBeacons)
          ],
        ),
        floatingActionButton: _buildScanningButton(),
        body: new Stack(
          children: <Widget>[
            (isScanning) ? _buildProgressBarTile() : new Container(),
            new ListView(
              children: tiles,
            )
          ],
        ),
      ),
    );
  }
}


int next(int min, int max) => min + _random.nextInt(max - min);

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
      // TODO: (High Priority) Set unique UUID's for beacons, differentiate between platform
     
      if(Platform.isIOS) {
         beaconBroadcast
          .setUUID('8b0ca750-e7a7-4e14-bd99-095477cb3e77')
          .setMajorId(1)
          .setMinorId(100)
          .start();
      }

    if(Platform.isAndroid) {
      // ! Note: BeaconBroadcast doesnt have specific Eddystone methods,
      // ! so setMajorId() is actually setting the beaconID.

      // TODO: (Low Priority) Rename BroadcastBeacon methods to make more sense for a specific platform
        beaconBroadcast
          .setUUID(next(1, 99).toString())
          .setMajorId(next(1, 99))
          .setMinorId(100)
          .start();
    }

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
