import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class RecordingUploadDialog extends StatefulWidget {
  final void Function({
    required String name,
    required String description,
    required String visibility,
    required File? thumbnail,
    required File? video,
  }) onUpload;

  const RecordingUploadDialog({Key? key, required this.onUpload})
      : super(key: key);

  @override
  State<RecordingUploadDialog> createState() => _RecordingUploadDialogState();
}

class _RecordingUploadDialogState extends State<RecordingUploadDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String visibility = 'Public';
  String? selectedBatch; // New state for selected batch
  File? thumbnail;
  File? video;
  bool _isUploading = false;

  // Hardcoded batch options (can be replaced with dynamic fetch later)
  final List<Map<String, String>> _batchOptions = [
    {'id': 'batch1', 'name': 'Batch 23'},
    {'id': 'batch2', 'name': 'Batch 24'},
    {'id': 'batch3', 'name': 'Batch 25'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.video_library,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Upload Class Recording',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _isUploading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Recording Name',
                  hintText: 'Enter recording name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 20),
              // Description
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 20),
              // Visibility Dropdown
              DropdownButtonFormField<String>(
                value: visibility,
                decoration: InputDecoration(
                  labelText: 'Visibility',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.visibility),
                ),
                items: [
                  'Public',
                  'Private',
                  'Batch',
                ]
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    visibility = val!;
                    if (visibility != 'Batch') selectedBatch = null;
                  });
                },
              ),
              // Show batch dropdown if visibility is 'Batch'
              if (visibility == 'Batch')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedBatch,
                    decoration: InputDecoration(
                      labelText: 'Select Batch',
                      hintText: 'Choose a batch',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.group),
                    ),
                    items: _batchOptions.map((batch) {
                      return DropdownMenuItem<String>(
                        value: batch['id'],
                        child: Text(batch['name']!),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedBatch = value;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 20),
              // Thumbnail Picker
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading
                        ? null
                        : () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.image);
                            if (result != null &&
                                result.files.single.path != null) {
                              setState(() {
                                thumbnail = File(result.files.single.path!);
                              });
                            }
                          },
                    icon: const Icon(Icons.image),
                    label: const Text('Attach Thumbnail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (thumbnail != null)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(thumbnail!, fit: BoxFit.cover),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Video Picker
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading
                        ? null
                        : () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.video);
                            if (result != null &&
                                result.files.single.path != null) {
                              setState(() {
                                video = File(result.files.single.path!);
                              });
                            }
                          },
                    icon: const Icon(Icons.video_file),
                    label: const Text('Attach Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (video != null)
                    Flexible(
                      child: Text(
                        video!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isUploading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : () async {
                              if (nameController.text.isEmpty ||
                                  video == null ||
                                  (visibility == 'Batch' &&
                                      selectedBatch == null)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Name, video, and batch (if Batch visibility) are required.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                _isUploading = true;
                              });
                              await Future.delayed(
                                  const Duration(milliseconds: 800));
                              widget.onUpload(
                                name: nameController.text,
                                description: descController.text,
                                visibility: visibility == 'Batch'
                                    ? (selectedBatch ?? '')
                                    : visibility,
                                thumbnail: thumbnail,
                                video: video,
                              );
                              if (mounted) {
                                setState(() {
                                  _isUploading = false;
                                });
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Upload',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
