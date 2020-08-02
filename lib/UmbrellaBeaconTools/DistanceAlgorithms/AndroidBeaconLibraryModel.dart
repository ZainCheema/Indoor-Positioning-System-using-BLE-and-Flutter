// https://ieeexplore.ieee.org/abstract/document/9051304
// https://stackoverflow.com/questions/21338031/radius-networks-ibeacon-ranging-fluctuation/21340147#21340147
// Credit to David Young of RadiusNetworks
import 'dart:math';

class AndroidBeaconLibraryModel {

  getCalculatedDistance(double rssi, int txAt1Meter) {
    print(txAt1Meter);
    var ratio = rssi * (1.0 / (txAt1Meter + 55));
    if(ratio < 1.0) {
      return pow(ratio, 10);
    } else {
      return (1.21112) * pow(ratio, 7.560861) + 0.251;
    }
  }
}