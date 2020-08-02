import 'dart:math';
import 'package:ml_linalg/linalg.dart';
import 'package:umbrella/Model/RangedBeaconData.dart';

// https://www.researchgate.net/publication/296700326_Problem_Investigation_of_Min-max_Method_for_RSSI_Based_Indoor_Localization
class Localization {
  RangedBeaconData rbd1;
  RangedBeaconData rbd2;
  RangedBeaconData rbd3;
  double distance1;
  double distance2;
  double distance3;

  bool conditionsMet = false;

  // Node which have been assigned absolute postions to the distance from it calculated by the receiver
  Map<String, Map<RangedBeaconData, double>> distanceToRangedNodes =
      new Map<String, Map<RangedBeaconData, double>>();

  addAnchorNode(String rbdID, Map<RangedBeaconData, double> rbdDistance) {
    String associatedKeyForLargestVal;
    distanceToRangedNodes[rbdID] = rbdDistance;

    if (distanceToRangedNodes.length >= 3) {
      conditionsMet = true;
      // If list is know greater than 3, remove the node with the largest distance value
      if (distanceToRangedNodes.length > 3) {
        print("Attempting to provide weighting...");
        double largestValue = 0;
        distanceToRangedNodes.forEach((k, v) {
          v.forEach((key, value) {
            if (value > largestValue) {
              largestValue = value;
              associatedKeyForLargestVal = k;
              print(
                  "Largest value: $largestValue, Associated key: $associatedKeyForLargestVal");
            }
          });
        });
        distanceToRangedNodes.remove(associatedKeyForLargestVal);
        if (distanceToRangedNodes.length == 3) {
          print("Set of beacons correctly weighted");
        }
      }
      rbd1 =
          distanceToRangedNodes.values.elementAt(0).keys.toList().elementAt(0);
      rbd2 =
          distanceToRangedNodes.values.elementAt(1).keys.toList().elementAt(0);
      rbd3 =
          distanceToRangedNodes.values.elementAt(2).keys.toList().elementAt(0);

      distance1 = distanceToRangedNodes.values
          .elementAt(0)
          .values
          .toList()
          .elementAt(0);
      distance2 = distanceToRangedNodes.values
          .elementAt(1)
          .values
          .toList()
          .elementAt(0);
      distance3 = distanceToRangedNodes.values
          .elementAt(2)
          .values
          .toList()
          .elementAt(0);
    } else {
      conditionsMet = false;
    }
  }

  // ignore: non_constant_identifier_names
  WeightedTrilaterationPosition() {
    double a = (-2 * rbd1.x) + (2 * rbd2.x);
    double b = (-2 * rbd1.y) + (2 * rbd2.y);
    double c = pow(distance1, 2) -
        pow(distance2, 2) -
        pow(rbd1.x, 2) +
        pow(rbd2.x, 2) -
        pow(rbd1.y, 2) +
        pow(rbd2.y, 2);
    double d = (-2 * rbd2.x) + (2 * rbd3.x);
    double e = (-2 * rbd2.y) + (2 * rbd3.y);
    double f = pow(distance2, 2) -
        pow(distance3, 2) -
        pow(rbd2.x, 2) +
        pow(rbd3.x, 2) -
        pow(rbd2.y, 2) +
        pow(rbd3.y, 2);

    double x = (c * e - f * b);
    x = x / (e * a - b * d);

    double y = (c * d - a * f);
    y = y / (b * d - a * e);

    var coordinates = {'x': x, 'y': y};

    print("Weighted x coordinate: " + x.toString());

    print("Weighted y coordinate: " + y.toString());

    return coordinates;
  }

  // ignore: non_constant_identifier_names
MinMaxPosition() {
    var xMin =
        Matrix.row([rbd1.x - distance1, rbd2.x - distance2, rbd3.x - distance3])
            .max();
    var xMax =
        Matrix.row([rbd1.x + distance1, rbd2.x + distance2, rbd3.x + distance3])
            .min();

    var yMin =
        Matrix.row([rbd1.y - distance1, rbd2.y - distance2, rbd3.y - distance3])
            .max();
    var yMax =
        Matrix.row([rbd1.y + distance1, rbd2.y + distance2, rbd3.y + distance3])
            .min();

    var x = (xMin + xMax) / 2;
    var y = (yMin + yMax) / 2;

    var coordinates = {'x': x, 'y': y};

    print("MinMax x coordinate: " + x.toString());

    print("MinMax y coordinate: " + y.toString());

    return coordinates;
  }
}
