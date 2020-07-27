import 'package:umbrella/Model/RangedBeaconData.dart';

class Trilateration {

  Trilateration(List<RangedBeaconData> pAnchorNodes) {
    anchorNodes = pAnchorNodes;
  }

  // Number of nodes which have been assigned absolute postions
  List<RangedBeaconData> anchorNodes = new List<RangedBeaconData>();
  
}