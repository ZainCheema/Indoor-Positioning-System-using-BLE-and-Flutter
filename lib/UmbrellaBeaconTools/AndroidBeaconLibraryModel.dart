// https://ieeexplore.ieee.org/abstract/document/9051304

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