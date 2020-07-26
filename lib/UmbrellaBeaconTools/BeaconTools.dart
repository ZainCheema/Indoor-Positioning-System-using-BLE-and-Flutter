import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:umbrella/UmbrellaBeaconTools/KalmanFilter.dart';
import 'package:umbrella/UmbrellaBeaconTools/LogDistancePathLossModel.dart';
import 'package:umbrella/UmbrellaBeaconTools/UmbrellaBeacon.dart';
import 'dart:math';
import 'package:umbrella/utils.dart';
import 'package:quiver/core.dart';
export 'package:flutter_ble_lib/flutter_ble_lib.dart' show ScanResult;

const EddystoneServiceId = "0000feaa-0000-1000-8000-00805f9b34fb";

List<Beacon> beaconList = new List();


// Adapted from: https://github.com/michaellee8/flutter_blue_beacon/blob/master/lib/beacon.dart
abstract class Beacon {
  final int tx;
  final ScanResult scanResult;

  double get rawRssi => scanResult.rssi.toDouble();

  double get kfRssi => KalmanFilter(0.125, 32, 1023, 0).getFilteredValue(rawRssi);

  String get name => scanResult.peripheral.name;


  String get id => scanResult.peripheral.identifier;

  int get hash;

  int get txAt1Meter => tx;

  double get rawRssiDistance {
    double ratio = rawRssi * 1.0 / (txAt1Meter);
    if (ratio < 1.0) {
      return pow(ratio, 10);
    } else {
      return (0.89976) * pow(ratio, 7.7095) + 0.111;
    }
  }

  double get rawLogDistance {
    return LogDistancePathLossModel(kfRssi).getCalculatedDistance();
  }

  double get kfRssiDistance {
    double ratio = rawRssi * 1.0 / (txAt1Meter);
    if (ratio < 1.0) {
      return pow(ratio, 10);
    } else {
      return (0.89976) * pow(ratio, 7.7095) + 0.111;
    }
  }

  const Beacon({@required this.tx, @required this.scanResult});

  static List<Beacon> fromScanResult(ScanResult scanResult) {
    try {
      EddystoneUID eddystoneBeacon = EddystoneUID.fromScanResult(scanResult);
      if(eddystoneBeacon != null) {
        debugPrint("Eddystone beacon found!");
        beaconList.add(eddystoneBeacon);
      }

    } on Exception catch(e) {
        print("ERROR: " + e.toString());
    }

    return beaconList;

  }
}

// Base class of all Eddystone beacons
abstract class Eddystone extends Beacon {
  const Eddystone(
      {@required this.frameType,
      @required int tx,
      @required ScanResult scanResult})
      : super(tx: tx, scanResult: scanResult);

  final int frameType;

  @override
  int get txAt1Meter => tx - 59;
}

class EddystoneUID extends Eddystone {
  final String namespaceId;
  final String beaconId;

  const EddystoneUID(
      {@required int frameType,
      @required this.namespaceId,
      @required this.beaconId,
      @required int tx,
      @required ScanResult scanResult})
      : super(tx: tx, scanResult: scanResult, frameType: frameType);

  factory EddystoneUID.fromScanResult(ScanResult scanResult) {
  // print("Scanning for Eddystone beacon");

    if(scanResult.advertisementData.serviceData == null) {
     // debugPrint("Service data is null");
      return null;
    }

    if (!scanResult.advertisementData.serviceData
        .containsKey(EddystoneServiceId)) {
      return null;
    }
    if (scanResult.advertisementData.serviceData[EddystoneServiceId].length <
        18) {
      return null;
    }
    if (scanResult.advertisementData.serviceData[EddystoneServiceId][0] !=
        0x00) {
      return null;
    }

   // print("Eddystone beacon detected!");

    List<int> rawBytes =
        scanResult.advertisementData.serviceData[EddystoneServiceId];
    var frameType = rawBytes[0];
    print("frameType: " + frameType.toString());
    var tx = byteToInt8(rawBytes[1]);
    print("tx power: " + tx.toString());
    var namespaceId = byteListToHexString(rawBytes.sublist(2, 12));
    print("namespace id: " + namespaceId);
    var beaconId = byteListToHexString(rawBytes.sublist(12, 18));
    print("beacon id: " + beaconId);

    return EddystoneUID(
        frameType: frameType,
        namespaceId: namespaceId,
        beaconId: beaconId,
        tx: tx,
        scanResult: scanResult);
  }

  int get hash => hashObjects([
        "EddystoneUID",
        EddystoneServiceId,
        this.frameType,
        this.namespaceId,
        this.beaconId,
        this.tx
      ]);
}

