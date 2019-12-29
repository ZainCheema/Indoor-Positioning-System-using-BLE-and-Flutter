import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'dart:math';
import 'package:umbrella/UmbrellaBeaconTools/utils.dart';
import 'package:quiver/core.dart';
export 'package:flutter_ble_lib/flutter_ble_lib.dart' show ScanResult;

const EddystoneServiceId = "0000feaa-0000-1000-8000-00805f9b34fb";
const IBeaconManufacturerId = 0x004C;

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
    return <Beacon>[
      EddystoneUID.fromScanResult(scanResult),
    ].where((b) => b != null).toList();
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
  int get txAt1Meter => tx - 41;
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
    List<int> rawBytes =
        scanResult.advertisementData.serviceData[EddystoneServiceId];
    var frameType = rawBytes[0];
    var tx = byteToInt8(rawBytes[1]);
    var namespaceId = byteListToHexString(rawBytes.sublist(2, 12));
    var beaconId = byteListToHexString(rawBytes.sublist(12, 18));
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

// class IBeacon extends Beacon {
//   final String uuid;
//   final int major;
//   final int minor;

//   const IBeacon(
//       {@required this.uuid,
//       @required this.major,
//       @required this.minor,
//       @required int tx,
//       @required ScanResult scanResult})
//       : super(tx: tx, scanResult: scanResult);

//   factory IBeacon.fromScanResult(ScanResult scanResult) {

//     scanResult.advertisementData.manufacturerData.

//     if (!scanResult.advertisementData.manufacturerData
//         .containsKey(IBeaconManufacturerId)) {
//       return null;
//     }
//     if (scanResult
//             .advertisementData.manufacturerData[IBeaconManufacturerId].length <
//         23) {
//       return null;
//     }
//     if (scanResult.advertisementData.manufacturerData[IBeaconManufacturerId]
//                 [0] !=
//             0x02 ||
//         scanResult.advertisementData.manufacturerData[IBeaconManufacturerId]
//                 [1] !=
//             0x15) {
//       return null;
//     }
//     List<int> rawBytes =
//         scanResult.advertisementData.manufacturerData[IBeaconManufacturerId];
//     var uuid = byteListToHexString(rawBytes.sublist(2, 18));
//     var major = twoByteToInt16(rawBytes[18], rawBytes[19]);
//     var minor = twoByteToInt16(rawBytes[20], rawBytes[21]);
//     var tx = byteToInt8(rawBytes[22]);
//     return IBeacon(
//       uuid: uuid,
//       major: major,
//       minor: minor,
//       tx: tx,
//       scanResult: scanResult,
//     );
//   }

//   int get hash => hashObjects([
//         "IBeacon",
//         IBeaconManufacturerId,
//         this.uuid,
//         this.major,
//         this.minor,
//         this.tx
//       ]);
// }
