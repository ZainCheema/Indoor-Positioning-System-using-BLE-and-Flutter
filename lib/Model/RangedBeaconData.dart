import 'package:flutter/foundation.dart';

class RangedBeaconData {
  List<double> rawRssi = new List<double>();
  // List<double> rawRssiStandardDeviation;
  List<double> rawRssiDistance = new List<double>();
  List<double> kfRssi = new List<double>();
//  List<double> kfRssiStandardDeviation;
  List<double> kfRssiDistance = new List<double>();

  RangedBeaconData(String pPhoneMake, String pBeaconUUID, int pTxAt1Meter) {
    phoneMake = pPhoneMake;
    beaconUUID = pBeaconUUID;
    txAt1Meter = pTxAt1Meter;
  }

  String phoneMake;
  String beaconUUID;
  int txAt1Meter;

  addRawRssi(double rssi) {
    rawRssi.add(rssi);
    print("rawRssi length: " + rawRssi.length.toString());
  }

  addkfRssi(double rssi) {
    kfRssi.add(rssi);
    print("kfRssi length: " + kfRssi.length.toString());
  }

  addRawRssiDistance(double distance) {
    rawRssiDistance.add(distance);
    print("rawRssiDistance length: " + rawRssiDistance.length.toString());
  }

  addkfRssiDistance(double distance) {
    kfRssiDistance.add(distance);
    print("kfRssiDistance length: " + kfRssiDistance.length.toString());
  }

  Map<String, dynamic> toJson() => {
        'phoneMake': phoneMake,
        'beaconUUID': beaconUUID,
        'txAt1Meter': txAt1Meter,
        'rawRssi': rawRssi,
        // 'rawRssiSD': rawRssiStandardDeviation,
        'rawRssiDist': rawRssiDistance,
        'kfRssi': kfRssi,
        //'kfRssiSD': kfRssiStandardDeviation,
        'kfRssiDist': kfRssiDistance,
      };
}
