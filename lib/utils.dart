import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

Future<Position> getLatLon() async {
  Position userLocation;
  return await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
      .then((location) {
    if (location != null) {
      debugPrint("Location: ${location.latitude},${location.longitude}");
      userLocation = location;
    }

    return userLocation;
  });
}

Future<List<Placemark>> getCountryCityStreet() async {
  var location = await getLatLon();

  var placemark = await Geolocator()
      .placemarkFromCoordinates(location.latitude, location.longitude);

  return placemark;
}

String angleToClockFace(int pAngle) {
  if (pAngle >= 0 && pAngle <= 30) {
    return " 1";
  }
  if (pAngle >= 31 && pAngle <= 60) {
    return "2";
  }
  if (pAngle >= 61 && pAngle <= 90) {
    return "3";
  }
  if (pAngle >= 91 && pAngle <= 120) {
    return "4";
  }
  if (pAngle >= 121 && pAngle <= 150) {
    return "5";
  }
  if (pAngle >= 151 && pAngle <= 180) {
    return "6";
  }
  if (pAngle >= 181 && pAngle <= 210) {
    return "7";
  }
  if (pAngle >= 211 && pAngle <= 240) {
    return "8";
  }
    if (pAngle >= 241 && pAngle <= 270) {
    return "9";
  }
    if (pAngle >= 271 && pAngle <= 300) {
    return "10";
  }
    if (pAngle >= 301 && pAngle <= 330) {
    return "11";
  }
    if (pAngle >= 331 && pAngle <= 360) {
    return "1";
  }

  return "oh dear, something went wrong";
}
