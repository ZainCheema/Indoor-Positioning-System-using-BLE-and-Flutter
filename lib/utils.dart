import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:umbrella/Model/BeaconInfo.dart';
import 'package:umbrella/UmbrellaBeaconTools/BeaconTools.dart';

final _random = new Random();

// Used in main.dart
int randomNumber(int min, int max) => min + _random.nextInt(max - min);

// Used in beacon_tools.dart
int byteToInt8(int b) =>
    new Uint8List.fromList([b]).buffer.asByteData().getInt8(0);

int twoByteToInt16(int v1, int v2) =>
    new Uint8List.fromList([v1, v2]).buffer.asByteData().getUint16(0);

String byteListToHexString(List<int> bytes) => bytes
    .map((i) => i.toRadixString(16).padLeft(2, '0'))
    .reduce((a, b) => (a + b));

beaconDebugInfo(BeaconInfo pBeacon, Beacon b) {
            debugPrint("Beacon " +
                pBeacon.phoneMake +
                "+" +
                pBeacon.beaconUUID +
                " is nearby!");
            print("tx power: " + b.tx.toString());
            print("Raw rssi: " + b.rawRssi.toString());
            print("Filtered rssi: " + b.kfRssi.toString());
            print("Log distance with raw rssi: " + b.rawRssiLogDistance.toString());
            print("Log distance with filtered rssi: " + b.kfRssiLogDistance.toString());
            print("RadiusNetworks distance with raw rssi: " + b.rawRssiLibraryDistance.toString());
            print("RadiusNetworks distance with filtered rssi: " + b.kfRssiLibraryDistance.toString());
} 

// https://arxiv.org/ftp/arxiv/papers/1912/1912.07801.pdf
errorRateforCoordinate(double realX, double estimatedX, double realY, double estimatedY) {
  return sqrt(pow((realX-estimatedX), 2) + pow((realY-estimatedY), 2));
}