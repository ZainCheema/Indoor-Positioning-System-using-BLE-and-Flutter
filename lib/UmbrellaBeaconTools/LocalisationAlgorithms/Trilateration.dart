import 'package:umbrella/Model/RangedBeaconData.dart';
// https://www.researchgate.net/publication/296700326_Problem_Investigation_of_Min-max_Method_for_RSSI_Based_Indoor_Localization
class Trilateration {

  Trilateration(List<RangedBeaconData> pAnchorNodes) {
    anchorNodes = pAnchorNodes;
  }

  // Number of nodes which have been assigned absolute postions
  List<RangedBeaconData> anchorNodes = new List<RangedBeaconData>();
  
}