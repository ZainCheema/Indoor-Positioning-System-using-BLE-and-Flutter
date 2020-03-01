import 'dart:typed_data';
import 'dart:math';
import 'dart:ui';
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



getUserLocation() async {
  return await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((location) {
    if (location != null) {
      debugPrint("Location: ${location.latitude},${location.longitude}");
    }
    
  });
}


// The following code will allow me to use any hex value for colour 
// as a MaterialColor

// Credit to: https://gist.github.com/filipvk
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}