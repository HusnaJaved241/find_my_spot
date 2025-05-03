import 'dart:io';
import 'package:find_my_spot/models/spot_model.dart';
import 'package:find_my_spot/providers/spots_provider.dart';
import 'package:find_my_spot/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'custom_text_field.dart';
import 'custom_button.dart';
import 'package:latlong2/latlong.dart';

class AddSpotDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descController;
  final LatLng selectedLocation;

  const AddSpotDialog({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descController,
    required this.selectedLocation,
  });

  @override
  State<AddSpotDialog> createState() => _AddSpotDialogState();
}

class _AddSpotDialogState extends State<AddSpotDialog> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _loadingImages = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _loadingImages = true);
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _images.add(image));
    }
    setState(() => _loadingImages = false);
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: widget.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Spot',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: "Take Photo",
                        icon: Icons.camera_alt,
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        label: "Choose from\nGallery",
                        icon: Icons.image,
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: "Name",
                  controller: widget.nameController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hint: "Description",
                  controller: widget.descController,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: "Cancel",
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: "Save",
                        onPressed: () async {
                          if (widget.formKey.currentState!.validate()) {
                            final spot = Spot(
                              name: widget.nameController.text,
                              description: widget.descController.text,
                              latitude: widget.selectedLocation.latitude,
                              longitude: widget.selectedLocation.longitude,
                              imagePaths:
                                  _images.map((xfile) => xfile.path).toList(),
                              createdAt: DateTime.now(),
                            );
                            final spotProvider = Provider.of<SpotsProvider>(
                              context,
                              listen: false,
                            );
                            spotProvider.addSpot(spot);
                            await DatabaseService.instance.addSpot(spot);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Spot saved successfully!\n\t ${spot.name} \n ${spot.description}',
                                ),
                              ),
                            );
                            widget.nameController.clear();
                            widget.descController.clear();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_loadingImages)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  )
                else if (_images.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_images[index].path),
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Text(
                    'No image selected',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
