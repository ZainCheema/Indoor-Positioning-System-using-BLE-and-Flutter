import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'beacon_tools.dart';
import 'package:flutter/foundation.dart';
export 'beacon_tools.dart';

class UmbrellaBeacon {
  // Singleton
  UmbrellaBeacon._();

  static UmbrellaBeacon _instance = new UmbrellaBeacon._();

  static UmbrellaBeacon get instance => _instance;

  Stream<Beacon> scan() {
    BleManager bleManager = BleManager();
    bleManager.createClient();

    bleManager.observeBluetoothState().listen((btState) {
      bleManager.startPeripheralScan().map((scanResult) {
        return Beacon.fromScanResult(scanResult);
      })
      .expand((b) => b)
      .where((b) => b != null);
    });
  }
}
