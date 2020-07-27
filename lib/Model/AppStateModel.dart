import 'dart:async';
import 'dart:io';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../utils.dart';
import 'BeaconInfo.dart';
import 'RangedBeaconData.dart';

class AppStateModel extends foundation.ChangeNotifier {
  // Singleton
  AppStateModel._();

  static AppStateModel _instance = new AppStateModel._();

  static AppStateModel get instance => _instance;

  bool wifiEnabled = false;
  bool bluetoothEnabled = false;
  bool gpsEnabled = false;
  bool gpsAllowed = false;

  PermissionStatus locationPermissionStatus = PermissionStatus.unknown;

  BeaconBroadcast beaconBroadcast = new BeaconBroadcast();
  String beaconStatusMessage;
  bool isBroadcasting = false;
  bool isScanning = false;

  Uuid uuid = new Uuid();

  String id = "";

  String phoneMake = "";

  // A list of all users in the app.
  List<BeaconInfo> anchorBeacons;

  CollectionReference anchorPath =
      Firestore.instance.collection('AnchorNodes');

  CollectionReference rangedPath =
      Firestore.instance.collection('RangedNodes');

  Stream<QuerySnapshot> beaconSnapshots;

  // ignore: cancel_subscriptions
  StreamSubscription beaconStream;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  void init() async {
    // This will check wifi, gps and bluetooth
    // If all these checks pass, create the user, then load the nearby users
    debugPrint("init() called");

    anchorBeacons = new List<BeaconInfo>();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    phoneMake = androidInfo.model.toString();
    print('Running on $phoneMake');

    id = uuid.v1().toString();
    id = id.replaceAll(RegExp('-'), '');

    if (Platform.isAndroid) {
      // For Android, the user's uuid has to be 20 chars long to conform
      // with Eddystones NamespaceId length
      // Also has to be without hyphens
      id = id.substring(0, 20);

      if (id.length == 20) {
        debugPrint("Android users ID is the correct format");
      } else {
        debugPrint('user ID was of an incorrect format');
        debugPrint(id);
        debugPrint("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      }
    }

    FlutterCompass.events.listen((double direction) async {
      //  // String facing = angleToClockFace(direction.round());
    });
    streamAnchorBeacons();
  }

  void registerBeacon(BeaconInfo bc, String path) async {
    await anchorPath.document(path).setData(bc.toJson());
  }

  void removeBeacon(String path) async {
    await anchorPath.document(path).delete();
  }

  void uploadRangedBeaconData(
      RangedBeaconData rbd, String beaconName) async {
    await rangedPath
        .document(beaconName)
        .setData(rbd.toJson());
  }

  void streamAnchorBeacons() {
    beaconSnapshots =
        Firestore.instance.collection(anchorPath.path).snapshots();

    beaconStream = beaconSnapshots.listen((s) {
      anchorBeacons.clear();
      for (var document in s.documents) {
        anchorBeacons = List.from(anchorBeacons);
        anchorBeacons.add(BeaconInfo.fromJson(document.data));
      }
      debugPrint("REGISTERED BEACONS: " + anchorBeacons.length.toString());
    });
  }

  List<BeaconInfo> getAnchorBeacons() {
    return anchorBeacons;
  }

  startBeaconBroadcast() async {
    BeaconBroadcast beaconBroadcast = BeaconBroadcast();

    var transmissionSupportStatus =
        await beaconBroadcast.checkTransmissionSupported();
    switch (transmissionSupportStatus) {
      case BeaconStatus.SUPPORTED:
        print("Beacon advertising is supported on this device");

        if (Platform.isAndroid) {
          debugPrint("User beacon uuid: " + id);

          beaconBroadcast
              .setUUID(id)
              .setMajorId(randomNumber(1, 99))
              .setTransmissionPower(-59)
              .setLayout(
                  BeaconBroadcast.EDDYSTONE_UID_LAYOUT)
              .start();
        }

        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
          beaconStatusMessage = "Beacon is now advertising";
          //   isBroadcasting = true;
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

  stopBeaconBroadcast() {
    beaconStatusMessage = "Beacon has stopped advertising";
    beaconBroadcast.stop();
    print(beaconStatusMessage);
  }

  checkGPS() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      print("GPS disabled");
      gpsEnabled = false;
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

  // Adapted from: https://dev.to/ahmedcharef/flutter-wait-user-enable-gps-permission-location-4po2#:~:text=Flutter%20Permission%20handler%20Plugin&text=Check%20if%20a%20permission%20is,permission%20status%20of%20location%20service.
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
}
