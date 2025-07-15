import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../components/recording_upload_dialog.dart';
import '../../services/user_service.dart'; // Correct import for RecordingUploadService
import '../../models/recording_model.dart';
import 'package:video_player/video_player.dart';

class TeacherRecordingsView extends StatefulWidget {
  const TeacherRecordingsView({Key? key}) : super(key: key);

  @override
  State<TeacherRecordingsView> createState() => _TeacherRecordingsViewState();
}

class _TeacherRecordingsViewState extends State<TeacherRecordingsView> {
  List<RecordingModel> recordings = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecordings();
  }

  Future<void> _fetchRecordings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetched = await RecordingUploadService.fetchRecordings();
      setState(() {
        recordings = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showRenameDialog(int index) {
    // Editing is not supported for immutable RecordingModel fields
    // You may implement a dialog to update the backend and refetch, but for now, just show info
    final video = recordings[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recording Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${video.name}'),
            Text('Description: ${video.description}'),
            Text('Visibility: ${video.visibility}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    // Deleting from backend is not implemented; just show info for now
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text('Delete functionality is not implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVideoPlayerDialog(String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _VideoPlayerDialogContent(videoUrl: videoUrl),
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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => RecordingUploadDialog(
              onUpload: ({
                required String name,
                required String description,
                required String visibility,
                required File? thumbnail,
                required File? video,
              }) async {
                if (video == null) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                try {
                  final bool success =
                      await RecordingUploadService.uploadRecording(
                    name: name,
                    description: description,
                    visibility: visibility,
                    thumbnail: thumbnail,
                    video: video!,
                    batchId: visibility == 'Batch' ? visibility : null,
                  );
                  Navigator.of(context).pop();
                  if (success) {
                    await _fetchRecordings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recording uploaded successfully'),
                        backgroundColor: Color(0xFF4788A8),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to upload recording'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        },
        backgroundColor: const Color(0xFF4788A8),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search and Filter Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search recordings...',
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.search,
                                        color: Colors.blue[700]),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onChanged: (value) {
                                    // TODO: Implement search logic
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(Icons.filter_list,
                                    color: Colors.blue[700]),
                                onPressed: () {
                                  // TODO: Implement filter logic
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Video List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recordings.length,
                          itemBuilder: (context, index) {
                            final video = recordings[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Card(
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: Colors.grey.withOpacity(0.08),
                                child: InkWell(
                                  onTap: () {
                                    _showVideoPlayerDialog(video.videoUrl);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: video.thumbnailUrl != null
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                        video.thumbnailUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: video.thumbnailUrl == null
                                              ? Center(
                                                  child: Icon(
                                                    Icons.play_circle_outline,
                                                    size: 32,
                                                    color: Colors.blue[700],
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                video.description,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                video.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today,
                                                      size: 15,
                                                      color: Color(0xFF6B6B6B)),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      video.uploadDate
                                                          .toString()
                                                          .split(' ')[0],
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF6B6B6B),
                                                        fontSize: 13,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Icon(Icons.visibility,
                                                      size: 15,
                                                      color: Color(0xFF6B6B6B)),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      video.visibility,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF6B6B6B),
                                                        fontSize: 13,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert,
                                              color: Colors.blue[700]),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showRenameDialog(index);
                                            } else if (value == 'delete') {
                                              _showDeleteConfirmation(index);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit,
                                                      size: 20,
                                                      color: Colors.blue[700]),
                                                  SizedBox(width: 8),
                                                  Text('Edit',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .blue[700])),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      size: 20,
                                                      color: Colors.redAccent),
                                                  SizedBox(width: 8),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .redAccent)),
                                                ],
                                              ),
                                            ),
                                          ],
                                          constraints: BoxConstraints.tightFor(
                                              width: 120),
                                        ),
                                      ],
                                    ),
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
                ),
    );
  }
}

class _VideoPlayerDialogContent extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerDialogContent({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<_VideoPlayerDialogContent> createState() =>
      _VideoPlayerDialogContentState();
}

class _VideoPlayerDialogContentState extends State<_VideoPlayerDialogContent> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isFullscreen = false;
  String? _error;

  final Color primaryColor = Colors.blue[700]!;
  final Color secondaryTextColor = Color(0xFF6B6B6B);
  final Color cardBgColor = Colors.white;
  final Color lightBgColor = Colors.blue[50]!;
  final Color activeColor = Colors.blue[900]!;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      }).catchError((e) {
        setState(() {
          _error = 'Failed to load video.';
        });
      });
    _controller.addListener(() {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds';
  }

  void _toggleFullscreen() async {
    setState(() => _isFullscreen = true);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    setState(() => _isFullscreen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Center(child: Text(_error!, style: TextStyle(color: Colors.red))),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio:
                _isInitialized ? _controller.value.aspectRatio : 16 / 9,
            child: _isInitialized
                ? VideoPlayer(_controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 12),
          if (_isInitialized)
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      _formatDuration(_controller.value.position),
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                    Expanded(
                      child: Slider(
                        value: _controller.value.position.inMilliseconds
                            .toDouble(),
                        min: 0,
                        max: _controller.value.duration.inMilliseconds
                            .toDouble(),
                        onChanged: (value) {
                          _controller
                              .seekTo(Duration(milliseconds: value.toInt()));
                        },
                        activeColor: primaryColor,
                        inactiveColor: lightBgColor,
                      ),
                    ),
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                          color: primaryColor),
                      onPressed: () {
                        setState(() {
                          _isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.fullscreen, color: primaryColor),
                      onPressed: _toggleFullscreen,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
