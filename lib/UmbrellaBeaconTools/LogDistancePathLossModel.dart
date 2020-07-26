// Related: https://iasj.net/iasj?func=fulltext&aId=123828

import 'dart:core';

import 'dart:math';

class LogDistancePathLossModel {

  // Rssi is the rssi measured from nearby beacon
  LogDistancePathLossModel(double rssiMeasured) {
    rssi = rssiMeasured;
  }

  // RSSI
  double rssi;
  // Rssd0, rssi measured at chosen reference distance do
  double referenceRss = -55;
  //do
  double referenceDistance = 1;
  // For line of sight in building
  // Gamma
  double pathLossExponent = 0.3;
  // Set to zero, as no large obstacle, used to mitigate for flat fading
  // Sigma
  double flatFadingMitigation = 0;

  double getCalculatedDistance() {
    double distance;
    double rssiDiff = rssi - referenceRss - flatFadingMitigation;

    double i =  pow(10, -(rssiDiff/ 10 * pathLossExponent));

    distance = referenceDistance * i;

    return distance;
  }
}