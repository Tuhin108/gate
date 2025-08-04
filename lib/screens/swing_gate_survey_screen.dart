import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gate_survey_app/models/survey_data.dart';
import 'package:gate_survey_app/utils/gate_logic.dart';
import 'package:gate_survey_app/widgets/dimension_input.dart';
import 'package:gate_survey_app/widgets/image_input.dart';
import 'package:gate_survey_app/widgets/gate_recommendation.dart';
import 'package:gate_survey_app/widgets/superimpose_image_input.dart';

class SwingGateSurveyScreen extends StatefulWidget {
  final Function(SwingGateSurveyData) onSave;

  const SwingGateSurveyScreen({super.key, required this.onSave});

  @override
  State<SwingGateSurveyScreen> createState() => _SwingGateSurveyScreenState();
}

class _SwingGateSurveyScreenState extends State<SwingGateSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedLocationPicture;
  File? _superimposedBaseImage;
  File? _superimposedOverlayImage;
  final TextEditingController _clearOpeningController = TextEditingController();
  final TextEditingController _heightRequiredController = TextEditingController();
  final TextEditingController _openingAngleLeaf1Controller = TextEditingController();
  final TextEditingController _openingAngleLeaf2Controller = TextEditingController();
  OpeningDirectionSwing? _openingDirection = OpeningDirectionSwing.inwardLeft;
  bool _provisionForCabling = false;
  bool _provisionForStorage = false;
  String _gateRecommendation = '';

  @override
  void dispose() {
    _clearOpeningController.dispose();
    _heightRequiredController.dispose();
    _openingAngleLeaf1Controller.dispose();
    _openingAngleLeaf2Controller.dispose();
    super.dispose();
  }

  void _updateRecommendation() {
    if (_formKey.currentState!.validate()) {
      final clearOpening = double.tryParse(_clearOpeningController.text) ?? 0.0;
      final openingAngleLeaf1 = double.tryParse(_openingAngleLeaf1Controller.text) ?? 0.0;
      final openingAngleLeaf2 = double.tryParse(_openingAngleLeaf2Controller.text);

      setState(() {
        _gateRecommendation = GateRecommendationLogic.getSwingGateRecommendation(
          clearOpening: clearOpening,
          openingDirection: _openingDirection!,
          openingAngleLeaf1: openingAngleLeaf1,
          openingAngleLeaf2: openingAngleLeaf2,
        );
      });
    }
  }

  void _saveSurvey() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final clearOpening = double.parse(_clearOpeningController.text);
      final heightRequired = double.parse(_heightRequiredController.text);
      final openingAngleLeaf1 = double.parse(_openingAngleLeaf1Controller.text);
      final openingAngleLeaf2 = double.tryParse(_openingAngleLeaf2Controller.text);

      final surveyData = SwingGateSurveyData(
        locationPicture: _selectedLocationPicture,
        clearOpening: clearOpening,
        heightRequired: heightRequired,
        openingDirection: _openingDirection!,
        openingAngleLeaf1: openingAngleLeaf1,
        openingAngleLeaf2: openingAngleLeaf2,
        provisionForCabling: _provisionForCabling,
        provisionForStorage: _provisionForStorage,
        superimposedImage: _superimposedOverlayImage,
        recommendation: _gateRecommendation,
      );

      widget.onSave(surveyData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swing Gate Survey'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageInput(
                label: 'Gate Location Picture',
                onSelectImage: (pickedImage) {
                  _selectedLocationPicture = pickedImage;
                },
              ),
              DimensionInput(
                label: 'Clear Opening',
                hintText: 'Enter clear opening in meters',
                controller: _clearOpeningController,
              ),
              DimensionInput(
                label: 'Height Required at Site',
                hintText: 'Enter height in meters',
                controller: _heightRequiredController,
              ),
              const SizedBox(height: 16),
              Text(
                'Opening Direction (from outside)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Column(
                children: OpeningDirectionSwing.values.map((direction) {
                  return RadioListTile<OpeningDirectionSwing>(
                    title: Text(direction.toString().split('.').last.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')),
                    value: direction,
                    groupValue: _openingDirection,
                    onChanged: (value) {
                      setState(() {
                        _openingDirection = value;
                      });
                    },
                  );
                }).toList(),
              ),
              DimensionInput(
                label: 'Opening Angle for Leaf 1',
                hintText: 'Enter angle in degrees (e.g., 90)',
                controller: _openingAngleLeaf1Controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an angle';
                  }
                  final angle = double.tryParse(value);
                  if (angle == null || angle < 0 || angle > 180) {
                    return 'Enter a valid angle (0-180)';
                  }
                  return null;
                },
              ),
              DimensionInput(
                label: 'Opening Angle for Leaf 2 (Optional)',
                hintText: 'Enter angle in degrees (e.g., 90)',
                controller: _openingAngleLeaf2Controller,
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Enter a valid number or leave empty';
                  }
                  final angle = double.tryParse(value ?? '');
                  if (angle != null && (angle < 0 || angle > 180)) {
                    return 'Enter a valid angle (0-180)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Provision for Cabling'),
                value: _provisionForCabling,
                onChanged: (value) {
                  setState(() {
                    _provisionForCabling = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Provision for Storage of Material'),
                value: _provisionForStorage,
                onChanged: (value) {
                  setState(() {
                    _provisionForStorage = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              SuperimposeImageInput(
                onSelectBaseImage: (image) {
                  _superimposedBaseImage = image;
                },
                onSelectOverlayImage: (image) {
                  _superimposedOverlayImage = image;
                },
                initialBaseImage: _selectedLocationPicture, // Use the location picture as base
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateRecommendation,
                child: const Text('Get Gate Recommendation'),
              ),
              if (_gateRecommendation.isNotEmpty)
                GateRecommendationDisplay(recommendation: _gateRecommendation),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSurvey,
                  child: const Text('Save Swing Gate Survey'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
