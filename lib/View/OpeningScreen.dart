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

TextEditingController xInput = new TextEditingController();
TextEditingController yInput = new TextEditingController();
bool allowTextInput = true;
bool coordinatesAreOK = true;
var xCoordinate;
var yCoordinate;

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
          
          appStateModel.stopBeaconBroadcast();
          appStateModel.isBroadcasting = false;
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
          
          appStateModel.stopBeaconBroadcast();
          appStateModel.isBroadcasting = false;
        }
      });
    });

    Wakelock.enable();

    appStateModel.checkGPS();

    bc = new BeaconInfo(
        phoneMake: phoneMake,
        beaconUUID: "",
        txPower: "-59",
        standardBroadcasting: "EddystoneUID");

    getBeaconInfo();
  }

  getBeaconInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      phoneMake = androidInfo.model.toString();

      bc = new BeaconInfo(
          phoneMake: phoneMake,
          beaconUUID: appStateModel.id,
          txPower: "-59",
          standardBroadcasting: "EddystoneUID");
    });

    beaconPath = phoneMake + "+" + appStateModel.id;
    print("Beacon path: " + beaconPath);
  }

  buildBroadcastButton() {
    if (appStateModel.isBroadcasting) {
      return new FloatingActionButton(
          child: new Icon(Icons.stop),
          backgroundColor: Colors.redAccent,
          onPressed: () {
            allowTextInput = true;
            appStateModel.stopBeaconBroadcast();
            appStateModel.removeBeacon(beaconPath);
            setState(() {
              appStateModel.isBroadcasting = false;
            });
          });
    } else {
      return new FloatingActionButton(
          child: new Icon(Icons.record_voice_over),
          backgroundColor: Colors.greenAccent,
          onPressed: () {
            // It is acceptable to leave both empty,
            // but you can't have one with text and the other without
            if (xInput.text.isEmpty & yInput.text.isEmpty) {
              coordinatesAreOK = false;
            } else {
              print("You have inputted something");
              xCoordinate = double.tryParse(xInput.text) ?? null;
              yCoordinate = double.tryParse(yInput.text) ?? null;

              // If either field can't be parsed into a double,
              // set coordinatesAreDouble to false
              if (xCoordinate == null || yCoordinate == null) {
                coordinatesAreOK = false;
                print("One of X and Y returned null when parse attempted");
                print("xCoordinate : $xCoordinate, yCoordinate: $yCoordinate");
              } else {
                coordinatesAreOK = true;
                print("xCoordinate : $xCoordinate, yCoordinate: $yCoordinate");
              }
            }

            appStateModel.checkGPS();
            appStateModel.checkLocationPermission();
            if (appStateModel.wifiEnabled &
                appStateModel.bluetoothEnabled &
                appStateModel.gpsEnabled &
                appStateModel.gpsAllowed &
                coordinatesAreOK) {
              allowTextInput = false;

              if (xCoordinate != null && yCoordinate != null) {
                bc.x = xCoordinate;
                bc.y = yCoordinate;
              }

              appStateModel.startBeaconBroadcast();
              appStateModel.registerBeacon(bc, beaconPath);
              setState(() {
                appStateModel.isBroadcasting = true;
              });
            } else if (!appStateModel.gpsAllowed) {
              showGenericDialog(context, "Location Permission Required",
                  "Location is needed to correctly advertise as a beacon");
            } else if (!appStateModel.gpsEnabled) {
              showGPSDialog(context);
            } else if (!coordinatesAreOK) {
              showGenericDialog(context, "Double check inputted coordinates",
                  "Values determined to be invalid");
            } else {
              showGenericDialog(
                  context,
                  "Wi-Fi, Bluetooth and GPS need to be on",
                  'Please check each of these in order to broadcast');
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
                    ? buildAlertTile(
                        context, "Wifi required to broadcast beacon")
                    : new Container(),
                (appStateModel.isBroadcasting)
                    ? buildProgressBarTile()
                    : new Container(),
                (blState != BluetoothState.POWERED_ON)
                    ? buildAlertTile(
                        context, "Please check whether Bluetooth is on")
                    : new Container(),
        Align(
          child: SingleChildScrollView(
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[ 
                BeaconInfoContainer(beaconInfo: bc),

                Container(
                  margin: EdgeInsets.only(top: 30, left: 30, right: 30),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Enter Cartesian X and Y Coordinates to use beacon as anchor for trilateration [REQUIRED]",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: allowTextInput,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          textAlign: TextAlign.center,
                          controller: xInput,
                          decoration: InputDecoration(
                            hintText: 'X (m)',
                            counterText: "",
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: allowTextInput,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          textAlign: TextAlign.center,
                          controller: yInput,
                          decoration: InputDecoration(
                            hintText: 'Y (m)',
                            counterText: "",
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20)),
                    ],
                  ),
                ),
              ],
            )),
          ),
        )
      ]),
    );
  }
}
