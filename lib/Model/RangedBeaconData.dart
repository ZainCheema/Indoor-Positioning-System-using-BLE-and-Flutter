
class RangedBeaconData {
  List<double> rawRssi = new List<double>();
  List<double> rawRssiDistance = new List<double>();
  List<double> kfRssi = new List<double>();
  List<double> kfRssiDistance = new List<double>();

  double x;
  double y;


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
  }

  addkfRssi(double rssi) {
    kfRssi.add(rssi);
  }

  addRawRssiDistance(double distance) {
    rawRssiDistance.add(distance);
  }

  addkfRssiDistance(double distance) {
    kfRssiDistance.add(distance);
  }

  Map<String, dynamic> toJson() => {
        'phoneMake': phoneMake,
        'beaconUUID': beaconUUID,
        'txAt1Meter': txAt1Meter,
        'rawRssi': rawRssi,
        'rawRssiDist': rawRssiDistance,
        'kfRssi': kfRssi,
        'kfRssiDist': kfRssiDistance,
      };
}
