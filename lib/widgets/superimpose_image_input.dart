import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class SuperimposeImageInput extends StatefulWidget {
  final Function(File?) onSelectBaseImage;
  final Function(File?) onSelectOverlayImage;
  final File? initialBaseImage;
  final File? initialOverlayImage;

  const SuperimposeImageInput({
    super.key,
    required this.onSelectBaseImage,
    required this.onSelectOverlayImage,
    this.initialBaseImage,
    this.initialOverlayImage,
  });

  @override
  State<SuperimposeImageInput> createState() => _SuperimposeImageInputState();
}

class _SuperimposeImageInputState extends State<SuperimposeImageInput> {
  File? _baseImage;
  File? _overlayImage;

  @override
  void initState() {
    super.initState();
    _baseImage = widget.initialBaseImage;
    _overlayImage = widget.initialOverlayImage;
  }

  Future<void> _pickImage(ImageSource source, bool isBaseImage) async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (imageFile == null) {
      return;
    }

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await File(imageFile.path).copy('${appDir.path}/$fileName');

    setState(() {
      if (isBaseImage) {
        _baseImage = savedImage;
        widget.onSelectBaseImage(savedImage);
      } else {
        _overlayImage = savedImage;
        widget.onSelectOverlayImage(savedImage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Superimpose Gate Drawing/Image',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_baseImage != null)
                Image.file(
                  _baseImage!,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                )
              else
                const Text('No Base Image Selected'),
              if (_overlayImage != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.7, // Adjust opacity for better visibility
                    child: Image.file(
                      _overlayImage!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Select Base Image'),
                onPressed: () => _pickImage(ImageSource.gallery, true),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Select Overlay Image'),
                onPressed: () => _pickImage(ImageSource.gallery, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
