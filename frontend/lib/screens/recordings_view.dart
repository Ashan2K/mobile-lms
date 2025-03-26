import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';

class RecordingsView extends StatelessWidget {
  const RecordingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recordings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 24),

              // Recording Items
              _buildRecordingItem('2025-01-20 Batch 23 night class recording'),
              const SizedBox(height: 16),
              _buildRecordingItem('2025-01-20 Batch 23 night class recording'),
              const SizedBox(height: 16),
              _buildRecordingItem('2025-01-20 Batch 23 night class recording'),
              const SizedBox(height: 16),
              _buildRecordingItem('2025-01-20 Batch 23 night class recording'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingItem(String title) {
    return Row(
      children: [
        Container(
          width: 160,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
      ],
    );
  }
}
