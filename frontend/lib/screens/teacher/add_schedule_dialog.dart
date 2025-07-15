import 'package:flutter/material.dart';
import '../../services/course_service.dart';
import '../../models/course_model.dart';

class AddScheduleDialog extends StatefulWidget {
  const AddScheduleDialog({Key? key}) : super(key: key);

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _zoomLinkController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = TimeOfDay.now();
  String _classType = 'Online';
  CourseModel? _selectedCourse;
  bool _loadingCourses = true;
  List<CourseModel> _courses = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _loadingCourses = true;
      _error = null;
    });
    try {
      final courses = await CourseService.fetchCourses();
      setState(() {
        _courses = courses;
        if (_courses.isNotEmpty) {
          _selectedCourse = _courses.first;
        }
        _loadingCourses = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load courses';
        _loadingCourses = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _zoomLinkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedCourse == null) return;

    // Validate zoom link for online classes
    if (_classType == 'Online' &&
        (_zoomLinkController.text.isEmpty ||
            !_zoomLinkController.text.contains('zoom'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Zoom link for online classes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final eventDate =
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final formattedTime = _selectedTime!.format(context);
    Navigator.of(context).pop({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'time': formattedTime,
      'students': 0,
      'classType': _classType,
      'zoomLink': _classType == 'Online' ? _zoomLinkController.text : null,
      'course': _selectedCourse?.courseName,
      'courseId': _selectedCourse?.courseId,
      'date': eventDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                        Icons.schedule,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add Schedule',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter class title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter class description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 16),
                // Date
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate!,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Select date' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Time
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime!,
                    );
                    if (picked != null) {
                      setState(() => _selectedTime = picked);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                      controller: TextEditingController(
                        text: _selectedTime == null
                            ? ''
                            : _selectedTime!.format(context),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Select time' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Class Type
                Row(
                  children: [
                    const Text('Class Type:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'Online',
                            groupValue: _classType,
                            onChanged: (v) => setState(() => _classType = v!),
                          ),
                          const Text('Online'),
                          Radio<String>(
                            value: 'Physical',
                            groupValue: _classType,
                            onChanged: (v) => setState(() => _classType = v!),
                          ),
                          const Text('Physical'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Zoom Link (only show for Online classes)
                if (_classType == 'Online') ...[
                  TextFormField(
                    controller: _zoomLinkController,
                    decoration: InputDecoration(
                      labelText: 'Zoom Link',
                      hintText: 'Enter Zoom meeting link',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.video_call),
                    ),
                    validator: (v) {
                      if (_classType == 'Online') {
                        if (v == null || v.isEmpty) {
                          return 'Enter Zoom link';
                        }
                        if (!v.contains('zoom')) {
                          return 'Please enter a valid Zoom link';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Course Dropdown
                if (_loadingCourses)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red))
                else
                  DropdownButtonFormField<CourseModel>(
                    value: _selectedCourse,
                    isExpanded: true,
                    items: _courses
                        .map((course) => DropdownMenuItem(
                              value: course,
                              child: Text(course.courseName,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCourse = v),
                    decoration: const InputDecoration(
                        labelText: 'Course', border: OutlineInputBorder()),
                    validator: (v) => v == null ? 'Select a course' : null,
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
