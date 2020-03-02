import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umbrella/View/NearbyScreen.dart';
import 'package:umbrella/View/NewPostScreen.dart';
import 'utils.dart';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'Model/PostModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'widgets.dart';
import 'UmbrellaBeaconTools/umbrella_beacon.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:random_words/random_words.dart';
import 'Model/ModelTester.dart';

var firestoreReference = Firestore.instance;

void main() => runApp(MyApp());

//PostCard postCard = PostCard(post: Post.fromJson(ModelTester.dummyPostJson));

List<PostCard> dummyPostCards = ModelTester.generateDummyPosts(5);


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Umbrella',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        themeMode: ThemeMode.dark,
        //home: MyHomePage(title: 'Umbrella Demo Home Page'),
        home: BottomNav());
  }
}

class BottomNav extends StatefulWidget {
  @override
  BottomNavState createState() {
    return BottomNavState();
  }
}

class BottomNavState extends State<BottomNav> {
    int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    MyHomePage(title: "Umbrella Demo"),
    NearbyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Feed'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              title: Text('Nearby'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ));
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

    Iterable<WordPair> userNames = generateWordPairs().take(5);

    for (int i = 0; i < userNames.length; i++) {
      firestoreReference
          .collection('User')
          .document(userNames.elementAt(i).toString())
          .setData(({"Person": "Added"}));
    }

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
          child: new Icon(Icons.add), onPressed: _startScan);
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

    for(int i = 0; i < dummyPostCards.length; i++) {
      tiles.add(dummyPostCards[i]);

    }

    tiles.addAll(_buildScanResultTiles());

    return new MaterialApp(
      theme: buildThemeData(),
      home: new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Umbrella'),
              const Image(image: AssetImage('assets/icons8-umbrella-24.png'))
            ],
          ),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.message), onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewPostScreen())
              );
            })
          ],
        ),
        floatingActionButton: _buildScanningButton(),
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            (isScanning) ? _buildProgressBarTile() : new Container(),
            new SubtitleBar(location: "Cottingham Road", userNumber: "5"),
            Expanded(
              child: new ListView(
              children: tiles,
              ),
            )
          ],
        ),
      ),
    );
  }
}

getUserStreet() async {
  Position location = getUserLocation();
  if(getUserLocation() != null) {
        List<Placemark> placemark =
        await Geolocator().placemarkFromCoordinates(location.latitude, location.longitude);

    String country = placemark[0].country;
    String postcode = placemark[0].postalCode;
    String street = placemark[0].thoroughfare;

    debugPrint("Current Postcode: " + postcode);

    var split = postcode.split(" ");

    var first = split[1];

    var second = first.split("");

    postcode = split[0] + " " + second[0];
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
      // TODO: (High Priority) Set unique UUID's for beacons, differentiate between platform

      if (Platform.isIOS) {
        beaconBroadcast
            .setUUID('8b0ca750-e7a7-4e14-bd99-095477cb3e77')
            .setMajorId(1)
            .setMinorId(100)
            .start();
      }

      if (Platform.isAndroid) {
        // ! Note: BeaconBroadcast doesnt have specific Eddystone methods,
        // ! so setMajorId() is actually setting the beaconID.

        // TODO: (Low Priority) Rename BroadcastBeacon methods to make more sense for a specific platform
        beaconBroadcast
            .setUUID(randomNumber(1, 99).toString())
            .setMajorId(randomNumber(1, 99))
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
