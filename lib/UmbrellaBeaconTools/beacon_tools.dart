import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:umbrella/UmbrellaBeaconTools/umbrella_beacon.dart';
import 'dart:math';
import 'package:umbrella/utils.dart';
import 'package:quiver/core.dart';
export 'package:flutter_ble_lib/flutter_ble_lib.dart' show ScanResult;

const EddystoneServiceId = "0000feaa-0000-1000-8000-00805f9b34fb";
const IBeaconManufacturerId = 0x004C;

List<Beacon> beaconList = new List();

abstract class Beacon {
  final int tx;
  final ScanResult scanResult;

  int get rssi => scanResult.rssi;

  String get name => scanResult.peripheral.name;

  String get id => scanResult.peripheral.identifier;

  int get hash;

  int get txAt1Meter => tx;

  double get distance {
    double ratio = rssi * 1.0 / (txAt1Meter);
    if (ratio < 1.0) {
      return pow(ratio, 10);
    } else {
      return (0.89976) * pow(ratio, 7.7095) + 0.111;
    }
  }

  const Beacon({@required this.tx, @required this.scanResult});

  // Returns the first found beacon protocol in one device
  static List<Beacon> fromScanResult(ScanResult scanResult) {
   // print("Started peripheral scan");

    try {
      EddystoneUID eddystoneBeacon = EddystoneUID.fromScanResult(scanResult);
      if(eddystoneBeacon != null) {
        debugPrint("Eddystone beacon found!");
        beaconList.add(eddystoneBeacon);
      }

      IBeacon iBeacon = IBeacon.fromScanResult(scanResult);
      if(iBeacon != null) {
        debugPrint("iBeacon beacon found!");
        beaconList.add(iBeacon);
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
   print("Scanning for Eddystone beacon");

    if(scanResult.advertisementData.serviceData == null) {
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

    print("Eddystone beacon detected!");

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

// ! Below are resources for how the iBeacon advertising packet is structured
// * https://support.kontakt.io/hc/en-gb/articles/201492492-iBeacon-advertising-packet-structure
// * https://stackoverflow.com/questions/18906988/what-is-the-ibeacon-bluetooth-profile/19040616#19040616

class IBeacon extends Beacon {
  final String uuid;
  final int major;
  final int minor;

  const IBeacon(
      {@required this.uuid,
      @required this.major,
      @required this.minor,
      @required int tx,
      @required ScanResult scanResult})
      : super(tx: tx, scanResult: scanResult);

  factory IBeacon.fromScanResult(ScanResult scanResult) {

    print("Scanning for iBeacon");

    Uint8List manuData = scanResult.advertisementData.manufacturerData;

    if(manuData == null) {
      return null;
    }

    // Find the index where the iBeacon manufacturer id is contained
    int manufacturerIdIndex = scanResult.advertisementData.manufacturerData
        .indexWhere((value) => value == IBeaconManufacturerId);
    //print("Index of iBeacon manufacturer id: " + manufacturerIdIndex.toString());

    if (scanResult.advertisementData.manufacturerData.length -
            manufacturerIdIndex +
            2 <
        23) {
      return null;
    }

    if (scanResult
                .advertisementData.manufacturerData[manufacturerIdIndex + 2] !=
            0x02 ||
        scanResult
                .advertisementData.manufacturerData[manufacturerIdIndex + 3] !=
            0x15) {
      return null;
    }
    
   List<int> rawBytes = scanResult.advertisementData.manufacturerData
        .sublist(manufacturerIdIndex);
    var uuid = byteListToHexString(rawBytes.sublist(4, 20));
    print("uuid: " + uuid);
    var major = twoByteToInt16(rawBytes[20], rawBytes[21]);
    print("major: " + major.toString());
    var minor = twoByteToInt16(rawBytes[22], rawBytes[23]);
    print("minor: " + minor.toString());
    var tx = byteToInt8(rawBytes[24]);
    print("tx power: " + tx.toString());

    return IBeacon(
      uuid: uuid,
      major: major,
      minor: minor,
      tx: tx,
      scanResult: scanResult,
    );
  }

  int get hash => hashObjects([
        "IBeacon",
        IBeaconManufacturerId,
        this.uuid,
        this.major,
        this.minor,
        this.tx
      ]);
}
