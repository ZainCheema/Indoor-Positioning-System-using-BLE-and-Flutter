import 'package:flutter/foundation.dart';

class BeaconInfo {

  BeaconInfo({@required this.phoneMake,@required this.beaconUUID,@required this.txPower,@required this.standardBroadcasting});

  final String phoneMake;
  final String beaconUUID;
  final String txPower;
  final String standardBroadcasting;
}