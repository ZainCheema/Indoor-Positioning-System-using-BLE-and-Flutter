import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:umbrella/Model/AppStateModel.dart';
import 'package:umbrella/Model/BeaconInfo.dart';
import 'package:umbrella/widgets.dart';
import '../styles.dart';
import 'package:wakelock/wakelock.dart';
import 'package:connectivity/connectivity.dart';

AppStateModel appStateModel = AppStateModel.instance;
String phoneMake = "";
BeaconInfo bc;
String beaconPath;

StreamSubscription networkChanges;
var connectivityResult;

StreamSubscription bluetoothChanges;
BluetoothState blState;



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

    appStateModel.requestLocationPermission();

    BleManager bleManager = BleManager();
    bleManager.createClient();

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

    Wakelock.enable();

    appStateModel.checkGPS();

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

    beaconPath = phoneMake + "+" + appStateModel.user.uuid;
    print("Beacon path: " + beaconPath);

  }

  buildBroadcastButton() {
    if (appStateModel.isBroadcasting) {
      return new FloatingActionButton(
          child: new Icon(Icons.stop),
          backgroundColor: Colors.red,
          onPressed: () {
            appStateModel.stopBeaconBroadcast();
            appStateModel.removeBeacon(beaconPath);
            setState(() {
              appStateModel.isBroadcasting = false;
            });
          });
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.record_voice_over),
          backgroundColor: Colors.lightGreen,
          onPressed: () {
            appStateModel.checkGPS();
            appStateModel.checkLocationPermission();
            if(appStateModel.wifiEnabled & 
              appStateModel.bluetoothEnabled & 
              appStateModel.gpsEnabled & 
              appStateModel.gpsAllowed) {
            appStateModel.startBeaconBroadcast();
            appStateModel.registerBeacon(bc, beaconPath);
            setState(() {
              appStateModel.isBroadcasting = true;
            });
            } else if (!appStateModel.gpsAllowed) {
              showGenericDialog(context, 
              "Location Permission Required", 
              "Location is needed to correctly advertise as a beacon");
            } 

            else if (!appStateModel.gpsEnabled) {
              showGPSDialog(context);
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
      floatingActionButton: buildBroadcastButton(),
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
