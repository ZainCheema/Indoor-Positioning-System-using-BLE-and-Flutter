import 'dart:async';

import 'package:android_intent/android_intent.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:umbrella/Model/AppStateModel.dart';
import 'package:umbrella/Model/BeaconInfo.dart';
import 'package:umbrella/widgets.dart';
import '../styles.dart';
import 'package:wakelock/wakelock.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';

AppStateModel appStateModel = AppStateModel.instance;
String phoneMake = "";
BeaconInfo bc;

final PermissionHandler permissionHandler = PermissionHandler();
Map<PermissionGroup, PermissionStatus> permissions;

StreamSubscription networkChanges;
var connectivityResult;

StreamSubscription bluetoothChanges;
BluetoothState blState;

bool wifiEnabled = false;
bool bluetoothEnabled = false;
bool gpsEnabled = false;
bool gpsAllowed = false;

class OpeningScreen extends StatefulWidget {
  @override
  OpeningScreenState createState() {
    return OpeningScreenState();
  }
}

class OpeningScreenState extends State<OpeningScreen> {
  @override
  void initState() {
    super.initState();
    print("Showing Opening Screen");

   // requestLocationPermission();

    BleManager bleManager = BleManager();
    bleManager.createClient();

    networkChanges = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        connectivityResult = result;
        if (connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile) {
          wifiEnabled = true;
          debugPrint("Network connected");
        } else {
          wifiEnabled = false;
        }
      });
    });

    bluetoothChanges = bleManager.observeBluetoothState().listen((s) {
      setState(() {
        blState = s;
        debugPrint("Bluetooth State changed");
        if (blState == BluetoothState.POWERED_ON) {
          bluetoothEnabled = true;
          debugPrint("Bluetooth is on");
        } else {
          bluetoothEnabled = false;
        }
      });
    });

    Wakelock.enable();

    checkGPS();

    bc = new BeaconInfo(
        phoneMake: phoneMake,
        beaconUUID: "",
        txPower: "-59",
        standardBroadcasting: "Eddystone");

    getBeaconInfo();
  }

  getBeaconInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      phoneMake = androidInfo.model.toString();

      bc = new BeaconInfo(
          phoneMake: phoneMake,
          beaconUUID: appStateModel.user.uuid,
          txPower: "-59",
          standardBroadcasting: "Eddystone");
    });
  }

  buildScanButton() {
    if (appStateModel.isBroadcasting) {
      return new FloatingActionButton(
          child: new Icon(Icons.stop),
          backgroundColor: Colors.red,
          onPressed: () {
            appStateModel.stopBeaconBroadcast();
            setState(() {
              appStateModel.isBroadcasting = false;
            });
          });
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.record_voice_over),
          backgroundColor: Colors.lightGreen,
          onPressed: () {
            checkGPS();
            checkLocationPermission();
            if(wifiEnabled & bluetoothEnabled & gpsEnabled & gpsAllowed) {
            appStateModel.startBeaconBroadcast();
            setState(() {
              appStateModel.isBroadcasting = true;
            });
            } else if (!gpsAllowed) {
              showGenericDialog(context, 
              "Location Permission Required", 
              "Location is needed to correctly advertise as a beacon");
            } 
            
            else {
              showGenericDialog(context,
              "Wi-Fi, Bluetooth and GPS need to be on",
              'Please check each of these in order to broadcast'
              );
            }
          });
    }
  }

  Future gpsDialog() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Can't get current location"),
                content:
                    const Text('Please enable GPS and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('OK'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ],
              );
            });
      }
    }
  }

  Future checkGPS() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      gpsDialog();
      return null;
    } else {
      print("GPS enabled");
      gpsEnabled = true;
    }
  }

  // Adapted from: https://dev.to/ahmedcharef/flutter-wait-user-enable-gps-permission-location-4po2#:~:text=Flutter%20Permission%20handler%20Plugin&text=Check%20if%20a%20permission%20is,permission%20status%20of%20location%20service.
  Future<bool> requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await requestPermission(PermissionGroup.location);
    if (granted != true) {
      gpsAllowed = false;
      requestLocationPermission();
    } else {
      gpsAllowed = true;
    }
    debugPrint('requestLocationPermission $granted');
    return granted;
  }

  Future<void> checkLocationPermission() async {
    gpsAllowed = await requestPermission(PermissionGroup.location);
  }

  @override
  Widget build(BuildContext context) {
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
      body: new Stack(children: <Widget>[
        (connectivityResult == ConnectivityResult.none)
            ? buildAlertTile(context, "Wifi required to broadcast beacon")
            : new Container(),
        (appStateModel.isBroadcasting)
            ? buildProgressBarTile()
            : new Container(),
        (blState != BluetoothState.POWERED_ON)
            ? buildAlertTile(context, "Please check whether Bluetooth is on")
            : new Container(),
        Center(child: BeaconInfoContainer(beaconInfo: bc))
      ]),
    );
  }
}
