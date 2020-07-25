import 'package:flutter/material.dart';
import 'package:umbrella/View/NearbyScreen.dart';
import 'package:umbrella/View/OpeningScreen.dart';
import 'package:umbrella/gpsLocation.dart';




class UmbrellaMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Umbrella', home: OpeningScreen());
  }
}
