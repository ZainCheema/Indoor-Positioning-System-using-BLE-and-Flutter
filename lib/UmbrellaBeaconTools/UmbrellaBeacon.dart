library umbrella_beacon;

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'BeaconTools.dart';
export 'BeaconTools.dart';

class UmbrellaBeacon {
  // Singleton
  UmbrellaBeacon._();

  static UmbrellaBeacon _instance = new UmbrellaBeacon._();

  static UmbrellaBeacon get instance => _instance;
  
  Stream<Beacon> scan(BleManager bleManager) => bleManager
      .startPeripheralScan(
        scanMode: ScanMode.lowLatency,
        callbackType: CallbackType.allMatches,
        allowDuplicates: true
      )
      .map((scanResult) {
        return Beacon.fromScanResult(scanResult);
      })
      .expand((b) => b)
      .where((b) => b != null);
}
