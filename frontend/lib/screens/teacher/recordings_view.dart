import 'package:flutter/material.dart';
import 'recording_upload.dart';

class TeacherRecordingsView extends StatefulWidget {
  const TeacherRecordingsView({Key? key}) : super(key: key);

  @override
  State<TeacherRecordingsView> createState() => _TeacherRecordingsViewState();
}

class _TeacherRecordingsViewState extends State<TeacherRecordingsView> {
  List<Map<String, String>> uploadedVideos = [
    {
      'title': '2025-01-20 Batch 23 night class recording',
      'subject': 'Course module 1',
      'date': '2025-01-20',
      'duration': '2h 30m',
      'batch': 'Batch 23'
    },
    {
      'title': '2025-01-22 Batch 23 morning class recording',
      'subject': 'Course module 2',
      'date': '2025-01-22',
      'duration': '1h 45m',
      'batch': 'Batch 23'
    },
    {
      'title': '2025-01-25 Batch 23 practical session',
      'subject': 'Course module 3',
      'date': '2025-01-25',
      'duration': '3h 00m',
      'batch': 'Batch 23'
    },
    {
      'title': '2025-01-28 Batch 23 theory class',
      'subject': 'Course module 4',
      'date': '2025-01-28',
      'duration': '2h 00m',
      'batch': 'Batch 23'
    },
  ];

  void _showRenameDialog(int index) {
    final TextEditingController titleController =
        TextEditingController(text: uploadedVideos[index]['title']);
    final TextEditingController subjectController =
        TextEditingController(text: uploadedVideos[index]['subject']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Recording'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter recording title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'Enter subject name',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                uploadedVideos[index]['title'] = titleController.text;
                uploadedVideos[index]['subject'] = subjectController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recording renamed successfully'),
                  backgroundColor: Color(0xFF4788A8),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4788A8),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text('Are you sure you want to delete this recording?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                uploadedVideos.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recording deleted successfully'),
                  backgroundColor: Color(0xFF4788A8),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1F1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Class Recordings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4788A8),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VideoUploadForm(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4788A8),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Uploads',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4788A8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${uploadedVideos.length} recordings available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uploadedVideos.length,
              itemBuilder: (context, index) {
                final video = uploadedVideos[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Handle video playback
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120,
                                height: 80,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4788A8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    size: 40,
                                    color: Color(0xFF4788A8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video['subject']!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4788A8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      video['title']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showRenameDialog(index);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(index);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                video['date']!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                video['duration']!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.group, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                video['batch']!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
