// https://ieeexplore.ieee.org/abstract/document/9051304
// https://stackoverflow.com/questions/21338031/radius-networks-ibeacon-ranging-fluctuation/21340147#21340147
// Credit to David Young of RadiusNetworks
import 'dart:math';

class AndroidBeaconLibraryModel {
  double getCalculatedDistance(double rssi, int txAt1Meter) {
    double ratio = rssi * 1.0 / (txAt1Meter);
    if(ratio < 1.0) {
      return pow(ratio, 10);
    } else {
      return (0.89976) * pow(ratio, 7.7095) + 0.111;
    }
  }
}