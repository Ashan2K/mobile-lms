import 'package:flutter/material.dart';
import '../../models/recording_model.dart';
import '../../services/user_service.dart';
import 'package:video_player/video_player.dart';

class RecordingsView extends StatefulWidget {
  const RecordingsView({Key? key}) : super(key: key);

  @override
  State<RecordingsView> createState() => _RecordingsViewState();
}

class _RecordingsViewState extends State<RecordingsView> {
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
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
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
                        const Text(
                          'Recordings',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ...recordings.map((rec) => Column(
                              children: [
                                _buildRecordingItem(rec),
                                const SizedBox(height: 16),
                              ],
                            )),
                        if (recordings.isEmpty)
                          const Center(child: Text('No recordings found.')),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRecordingItem(RecordingModel recording) {
    return InkWell(
      onTap: () => _showVideoPlayerDialog(recording.videoUrl),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: recording.thumbnailUrl != null
                  ? DecorationImage(
                      image: NetworkImage(recording.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: recording.thumbnailUrl == null
                ? const Icon(Icons.videocam, size: 48, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recording.name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 4),
                Text(
                  recording.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 4),
                    Text(
                      recording.uploadDate.toString().split(' ')[0],
                      style: const TextStyle(
                          color: Color(0xFF6B6B6B), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.play_circle_outline, color: Color(0xFF4788A8)),
            onPressed: () => _showVideoPlayerDialog(recording.videoUrl),
          ),
        ],
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
  String? _error;

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

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Text(_error!, style: const TextStyle(color: Colors.red))),
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
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B6B6B)),
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
                        activeColor: const Color(0xFF4788A8),
                        inactiveColor: Colors.grey[300],
                      ),
                    ),
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B6B6B)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFF4788A8)),
                      onPressed: () {
                        setState(() {
                          _isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
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
