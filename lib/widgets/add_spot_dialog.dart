import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_text_field.dart';
import 'custom_button.dart';

class AddSpotDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descController;

  const AddSpotDialog({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descController,
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
    const darkColor = Color(0xFF2C2F3C);

    return Dialog(
      backgroundColor: const Color(0xFF1D1F2C),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: "Take Photo",
                        icon: Icons.camera_alt,
                        bgColor: Colors.orange,
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        label: "Choose from\nGallery",
                        icon: Icons.image,
                        bgColor: darkColor,
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(hint: "Name", controller: widget.nameController),
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
                        bgColor: darkColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: "Save",
                        bgColor: Colors.green,
                        onPressed: () {
                          if (widget.formKey.currentState!.validate()) {
                            // TODO: Save spot data and images to DB
                            Navigator.pop(context);
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
                    child: CircularProgressIndicator(color: Colors.white),
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
                    style: TextStyle(color: Colors.grey),
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
