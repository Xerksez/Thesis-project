import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/shared/services/task_service.dart';
import 'image_carousel.dart';

class TaskUpdateDialog extends StatefulWidget {
  final Function(String, List<File>) onSave;
  final int jobId;

  const TaskUpdateDialog({super.key, required this.onSave, required this.jobId});

  @override
  _TaskUpdateDialogState createState() => _TaskUpdateDialogState();
}

class _TaskUpdateDialogState extends State<TaskUpdateDialog> {
  final TextEditingController _commentController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveUpdate() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('comment can not be empty.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int actualizationId = await TaskService.createTaskActualization(
          widget.jobId, _commentController.text);

      if (_selectedImages.isNotEmpty) {
        for (File image in _selectedImages) {
          await TaskService.uploadImage(actualizationId, image);
        }
      }

      widget.onSave(_commentController.text, _selectedImages);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualization is saved.')),
      );
    } catch (e) {
      print('Failed to save update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while saving.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Make update',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'add comment',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedImages.isNotEmpty)
              ImageCarousel(images: _selectedImages, onRemoveImage: _removeImage),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Add photo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Chose photo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            _isLoading ? 'Saving...' : 'Save',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
