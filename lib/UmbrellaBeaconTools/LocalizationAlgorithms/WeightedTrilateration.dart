import 'dart:collection';
import 'dart:math';
import 'package:umbrella/Model/RangedBeaconData.dart';

// https://www.researchgate.net/publication/296700326_Problem_Investigation_of_Min-max_Method_for_RSSI_Based_Indoor_Localization
// https://math.stackexchange.com/questions/884807/find-x-location-using-3-known-x-y-location-using-trilateration
//https://journals.sagepub.com/doi/full/10.5772/63246
class WeightedTrilateration {
  RangedBeaconData rbd1;
  RangedBeaconData rbd2;
  RangedBeaconData rbd3;
  double distance1;
  double distance2;
  double distance3;

  bool conditionsMet = false;

  //HashMap<String, RangedBeaconData> beaconUUIDtoRangedBeacon = new HashMap<String, RangedBeaconData>();

  // Node which have been assigned absolute postions to the distance from it calculated by the receiver
  Map<String, Map<RangedBeaconData, double>> distanceToRangedNodes =
      new Map<String, Map<RangedBeaconData, double>>();

  addAnchorNode(String rbdID, Map<RangedBeaconData, double> rbdDistance) {
      distanceToRangedNodes[rbdID] = rbdDistance;


    if (distanceToRangedNodes.length >= 3) {
      print("Enough nodes detected to perform trilateration");
      // If list is know greater than 3, remove the node with the largest distance value
      if (distanceToRangedNodes.length > 3) {
        var associatedKey;
        double largestValue = 0;
        distanceToRangedNodes.forEach((k, v) {
          v.forEach((key, value) {
            if (value > largestValue) {
              largestValue = value;
              associatedKey = key;
            }
          });
         v.remove(associatedKey);
        });

      }
      rbd1 = distanceToRangedNodes.values.elementAt(0).keys.toList().elementAt(0);
      rbd2 = distanceToRangedNodes.values.elementAt(1).keys.toList().elementAt(1);
      rbd3 = distanceToRangedNodes.values.elementAt(2).keys.toList().elementAt(2);

      distance1 = distanceToRangedNodes.values.elementAt(0).values.elementAt(0);
      distance2 = distanceToRangedNodes.values.elementAt(1).values.elementAt(1);
      distance3 = distanceToRangedNodes.values.elementAt(2).values.elementAt(2);
      calculatePosition();
    }
  }

  calculatePosition() {
    print("calculatePosition() reached");

    var coordinates = [];

    var x =
        (pow(distance1, 2) - pow(distance2, 2)) + pow(rbd2.x, 2) / 2 * rbd2.x;

    print("Calculated x coordinate: " + x.toString());

    var y = ((pow(distance1, 2) - pow(distance3, 2)) +
            pow(rbd3.x, 2) +
            pow(rbd3.y, 2) -
            (2 * rbd3.x * rbd1.x)) /
        2 *
        rbd1.y;

    print("Calculated y coordinate: " + y.toString());

    coordinates.add(x);
    coordinates.add(y);

    return coordinates;
  }
}
