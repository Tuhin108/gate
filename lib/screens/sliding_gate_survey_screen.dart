import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gate_survey_app/models/survey_data.dart';
import 'package:gate_survey_app/utils/gate_logic.dart';
import 'package:gate_survey_app/widgets/dimension_input.dart';
import 'package:gate_survey_app/widgets/image_input.dart';
import 'package:gate_survey_app/widgets/gate_recommendation.dart';
import 'package:gate_survey_app/widgets/superimpose_image_input.dart';

class SlidingGateSurveyScreen extends StatefulWidget {
  final Function(SlidingGateSurveyData) onSave;

  const SlidingGateSurveyScreen({super.key, required this.onSave});

  @override
  State<SlidingGateSurveyScreen> createState() => _SlidingGateSurveyScreenState();
}

class _SlidingGateSurveyScreenState extends State<SlidingGateSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedLocationPicture;
  File? _superimposedBaseImage;
  File? _superimposedOverlayImage;
  final TextEditingController _clearOpeningController = TextEditingController();
  final TextEditingController _heightRequiredController = TextEditingController();
  final TextEditingController _parkingSpaceController = TextEditingController();
  OpeningDirectionSliding? _openingDirection = OpeningDirectionSliding.left;
  bool _provisionForCabling = false;
  bool _provisionForStorage = false;
  String _gateRecommendation = '';

  @override
  void dispose() {
    _clearOpeningController.dispose();
    _heightRequiredController.dispose();
    _parkingSpaceController.dispose();
    super.dispose();
  }

  void _updateRecommendation() {
    if (_formKey.currentState!.validate()) {
      final clearOpening = double.tryParse(_clearOpeningController.text) ?? 0.0;
      final parkingSpace = double.tryParse(_parkingSpaceController.text) ?? 0.0;

      setState(() {
        _gateRecommendation = GateRecommendationLogic.getSlidingGateRecommendation(
          clearOpening: clearOpening,
          parkingSpace: parkingSpace,
          openingDirection: _openingDirection!,
        );
      });
    }
  }

  void _saveSurvey() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final clearOpening = double.parse(_clearOpeningController.text);
      final heightRequired = double.parse(_heightRequiredController.text);
      final parkingSpace = double.parse(_parkingSpaceController.text);

      final surveyData = SlidingGateSurveyData(
        locationPicture: _selectedLocationPicture,
        clearOpening: clearOpening,
        heightRequired: heightRequired,
        parkingSpace: parkingSpace,
        openingDirection: _openingDirection!,
        provisionForCabling: _provisionForCabling,
        provisionForStorage: _provisionForStorage,
        superimposedImage: _superimposedOverlayImage, // The overlay image is the "drawing"
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
        title: const Text('Sliding Gate Survey'),
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
              DimensionInput(
                label: 'Parking Space',
                hintText: 'Enter parking space in meters',
                controller: _parkingSpaceController,
              ),
              const SizedBox(height: 16),
              Text(
                'Opening Direction (from outside)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Column(
                children: OpeningDirectionSliding.values.map((direction) {
                  return RadioListTile<OpeningDirectionSliding>(
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
                  child: const Text('Save Sliding Gate Survey'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
