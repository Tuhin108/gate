import 'dart:io';

enum GateType { sliding, swing }
enum OpeningDirectionSliding { left, right, biParting }
enum OpeningDirectionSwing { inwardLeft, inwardRight, outwardLeft, outwardRight }

abstract class GateSurveyData {
  final GateType type;
  final File? locationPicture;
  final double clearOpening;
  final double heightRequired;
  final bool provisionForCabling;
  final bool provisionForStorage;
  final File? superimposedImage; // For superimposing gate drawing/image

  GateSurveyData({
    required this.type,
    this.locationPicture,
    required this.clearOpening,
    required this.heightRequired,
    required this.provisionForCabling,
    required this.provisionForStorage,
    this.superimposedImage,
  });

  Map<String, dynamic> toMap();
}

class SlidingGateSurveyData extends GateSurveyData {
  final double parkingSpace;
  final OpeningDirectionSliding openingDirection;
  final String recommendation;

  SlidingGateSurveyData({
    File? locationPicture,
    required double clearOpening,
    required double heightRequired,
    required this.parkingSpace,
    required this.openingDirection,
    required bool provisionForCabling,
    required bool provisionForStorage,
    File? superimposedImage,
    required this.recommendation,
  }) : super(
          type: GateType.sliding,
          locationPicture: locationPicture,
          clearOpening: clearOpening,
          heightRequired: heightRequired,
          provisionForCabling: provisionForCabling,
          provisionForStorage: provisionForStorage,
          superimposedImage: superimposedImage,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'Gate Type': 'Sliding',
      'Location Picture Path': locationPicture?.path ?? 'N/A',
      'Clear Opening (m)': clearOpening,
      'Height Required (m)': heightRequired,
      'Parking Space (m)': parkingSpace,
      'Opening Direction': openingDirection.toString().split('.').last,
      'Provision for Cabling': provisionForCabling ? 'Yes' : 'No',
      'Provision for Storage': provisionForStorage ? 'Yes' : 'No',
      'Superimposed Image Path': superimposedImage?.path ?? 'N/A',
      'Recommendation': recommendation,
    };
  }
}

class SwingGateSurveyData extends GateSurveyData {
  final OpeningDirectionSwing openingDirection;
  final double openingAngleLeaf1;
  final double? openingAngleLeaf2; // Optional for single leaf swing gates
  final String recommendation;

  SwingGateSurveyData({
    File? locationPicture,
    required double clearOpening,
    required double heightRequired,
    required this.openingDirection,
    required this.openingAngleLeaf1,
    this.openingAngleLeaf2,
    required bool provisionForCabling,
    required bool provisionForStorage,
    File? superimposedImage,
    required this.recommendation,
  }) : super(
          type: GateType.swing,
          locationPicture: locationPicture,
          clearOpening: clearOpening,
          heightRequired: heightRequired,
          provisionForCabling: provisionForCabling,
          provisionForStorage: provisionForStorage,
          superimposedImage: superimposedImage,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      'Gate Type': 'Swing',
      'Location Picture Path': locationPicture?.path ?? 'N/A',
      'Clear Opening (m)': clearOpening,
      'Height Required (m)': heightRequired,
      'Opening Direction': openingDirection.toString().split('.').last,
      'Opening Angle Leaf 1 (deg)': openingAngleLeaf1,
      'Opening Angle Leaf 2 (deg)': openingAngleLeaf2 ?? 'N/A',
      'Provision for Cabling': provisionForCabling ? 'Yes' : 'No',
      'Provision for Storage': provisionForStorage ? 'Yes' : 'No',
      'Superimposed Image Path': superimposedImage?.path ?? 'N/A',
      'Recommendation': recommendation,
    };
  }
}
