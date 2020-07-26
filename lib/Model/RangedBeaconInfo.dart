import 'package:flutter/foundation.dart';


class RangedBeaconInfo{
  
  RangedBeaconInfo({
    @required this.phoneMake,
    @required this.beaconUUID,
    @required this.directionFaced,
    @required this.rawRssi,
    @required this.rawRssiStandardDeviation,
    @required this.rawRssiDistance,
    @required this.kfRssi,
    @required this.kfRssiStandardDeviation,
    @required this.kfRssiDistance
  });

  final String phoneMake;
  final String beaconUUID;
  final List<double> directionFaced;
  final List<double> rawRssi;
  final List<double> rawRssiStandardDeviation;
  final List<double> rawRssiDistance;
  final List<double> kfRssi;
  final List<double> kfRssiStandardDeviation;
  final List<double> kfRssiDistance;

    Map<dynamic, dynamic> toJson() => {
    'phoneMake': phoneMake,
    'beaconUUID': beaconUUID,
    'directionFaced': directionFaced,
    'rawRssi': rawRssi,
    'rawRssiSD': rawRssiStandardDeviation,
    'rawRssiDist': rawRssiDistance,
    'kfRssi': kfRssi,
    'kfRssiSD': kfRssiStandardDeviation,
    'kfRssiDist': kfRssiDistance,
  };

}