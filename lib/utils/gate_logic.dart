import 'package:gate_survey_app/models/survey_data.dart';

class GateRecommendationLogic {
  static String getSlidingGateRecommendation({
    required double clearOpening,
    required double parkingSpace,
    required OpeningDirectionSliding openingDirection,
  }) {
    if (clearOpening > 6.0 && parkingSpace > 3.0 && openingDirection == OpeningDirectionSliding.biParting) {
      return 'Double Sliding Gate (Large Opening)';
    } else if (clearOpening > 3.0 && parkingSpace > 1.5) {
      return 'Single Sliding Gate (Standard)';
    } else if (clearOpening <= 3.0 && parkingSpace > 1.0) {
      return 'Compact Sliding Gate';
    } else {
      return 'Custom Sliding Gate Solution Recommended';
    }
  }

  static String getSwingGateRecommendation({
    required double clearOpening,
    required OpeningDirectionSwing openingDirection,
    required double openingAngleLeaf1,
    double? openingAngleLeaf2,
  }) {
    if (clearOpening > 4.0 && openingAngleLeaf1 >= 90 && (openingAngleLeaf2 == null || openingAngleLeaf2 >= 90)) {
      return 'Double Swing Gate (Wide Opening)';
    } else if (clearOpening > 2.0 && openingAngleLeaf1 >= 90) {
      return 'Single Swing Gate (Standard)';
    } else if (clearOpening <= 2.0 && openingAngleLeaf1 < 90) {
      return 'Compact Swing Gate (Limited Angle)';
    } else {
      return 'Custom Swing Gate Solution Recommended';
    }
  }
}
