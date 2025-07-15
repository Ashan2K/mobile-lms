import 'package:flutter/material.dart';
import 'exam_screen.dart';
import 'package:video_player/video_player.dart';
import '../../models/recording_model.dart';
import '../../services/user_service.dart';
import '../../models/mock_exam.dart';
import '../../services/mock_exam_service.dart';
import '../../models/schedule_model.dart';
import '../../services/schedule_service.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'recordings_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  Timer? _carouselTimer;

  List<RecordingModel> _latestRecordings = [];
  bool _isLoadingRecordings = true;
  String? _recordingsError;

  List<MockExam> _latestMockExams = [];
  bool _isLoadingMockExams = true;
  String? _mockExamsError;

  List<ScheduleModel> _upcomingSessions = [];
  bool _isLoadingSessions = true;
  String? _sessionsError;
  bool _showAllSessions = false;

  @override
  void initState() {
    super.initState();
    _fetchLatestRecordings();
    _fetchLatestMockExams();
    _fetchUpcomingSessions();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_latestRecordings.isNotEmpty && _pageController.hasClients) {
        setState(() {
          final count =
              _latestRecordings.length < 3 ? _latestRecordings.length : 3;
          if (count > 0) {
            _currentPageIndex = (_currentPageIndex + 1) % count;
            _pageController.animateToPage(
              _currentPageIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  Future<void> _fetchLatestRecordings() async {
    setState(() {
      _isLoadingRecordings = true;
      _recordingsError = null;
    });
    try {
      final recordings = await RecordingUploadService.fetchRecordings();
      recordings.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
      setState(() {
        _latestRecordings = recordings.take(2).toList();
        _isLoadingRecordings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recordingsError = 'Failed to load videos';
        _isLoadingRecordings = false;
      });
    }
  }

  Future<void> _fetchLatestMockExams() async {
    setState(() {
      _isLoadingMockExams = true;
      _mockExamsError = null;
    });
    try {
      final exams = await MockExamService().getMockExams();
      exams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _latestMockExams = exams.take(2).toList();
        _isLoadingMockExams = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mockExamsError = 'Failed to load mock exams';
        _isLoadingMockExams = false;
      });
    }
  }

  Future<void> _fetchUpcomingSessions() async {
    setState(() {
      _isLoadingSessions = true;
      _sessionsError = null;
    });

    try {
      final user = await AuthService.getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }

      // Get enrolled courses for the user
      final enrolledCourses = await CourseService.fetchEnrolledCourses(user.id);
      if (enrolledCourses.isEmpty) {
        setState(() {
          _upcomingSessions = [];
          _isLoadingSessions = false;
        });
        return;
      }

      // Get course IDs from enrolled courses
      final courseIds = enrolledCourses
          .where((course) => course.courseId != null)
          .map((course) => course.courseId!)
          .toList();

      // Fetch upcoming schedules for enrolled courses
      final allSchedules = await ScheduleService.fetchUpcomingSchedules();

      // Filter schedules for enrolled courses and online sessions only
      final filteredSchedules = allSchedules.where((schedule) {
        return courseIds.contains(schedule.courseId) &&
            schedule.classType.toLowerCase() == 'online';
      }).toList();

      // Sort by date and time
      filteredSchedules.sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        if (dateComparison != 0) return dateComparison;
        return a.time.compareTo(b.time);
      });

      setState(() {
        _upcomingSessions = filteredSchedules;
        _isLoadingSessions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sessionsError = 'Failed to load live sessions';
        _isLoadingSessions = false;
      });
    }
  }

  Future<void> _joinSession(String zoomLink) async {
    try {
      final Uri url = Uri.parse(zoomLink.trim());
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Zoom link')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining session: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Today';
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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
  void dispose() {
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _fetchLatestRecordings(),
            _fetchLatestMockExams(),
            _fetchUpcomingSessions(),
          ]);
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 24),

                // Carousel Slider
                SizedBox(
                  height: 180,
                  child: _isLoadingRecordings
                      ? const Center(child: CircularProgressIndicator())
                      : _latestRecordings.isEmpty
                          ? const Center(child: Text('No recent videos found.'))
                          : PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPageIndex = index;
                                });
                              },
                              itemCount: _latestRecordings.length < 3
                                  ? _latestRecordings.length
                                  : 3,
                              itemBuilder: (context, index) {
                                final rec = _latestRecordings[index];
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecordingPlayerScreen(recording: rec),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          image: rec.thumbnailUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      rec.thumbnailUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: rec.thumbnailUrl == null
                                            ? const Center(
                                                child: Icon(Icons.videocam,
                                                    size: 48,
                                                    color: Colors.grey),
                                              )
                                            : null,
                                      ),
                                      // Play icon overlay
                                      Positioned.fill(
                                        child: Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: const Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.white,
                                              size: 56,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Title overlay at bottom
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(16)),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black54,
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          child: Text(
                                            rec.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 4,
                                                  color: Colors.black45,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(height: 8),

                // Carousel Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _latestRecordings.length < 3 ? _latestRecordings.length : 3,
                    (index) => Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[700]!.withOpacity(
                          _currentPageIndex == index ? 0.9 : 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Live Session Section
                const Text(
                  'Live session',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingSessions
                    ? const Center(child: CircularProgressIndicator())
                    : _sessionsError != null
                        ? Center(child: Text(_sessionsError!))
                        : _upcomingSessions.isEmpty
                            ? Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFFEEEEEE)),
                                    bottom:
                                        BorderSide(color: Color(0xFFEEEEEE)),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No upcoming live sessions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  ...(_showAllSessions
                                          ? _upcomingSessions
                                          : _upcomingSessions.take(2))
                                      .map((session) => Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                    color: Color(0xFFEEEEEE)),
                                                bottom: BorderSide(
                                                    color: Color(0xFFEEEEEE)),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        session.title,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF1E1E1E),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        session.courseName,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF6B6B6B),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 14,
                                                            color: Color(
                                                                0xFF6B6B6B),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            '${_formatDate(session.date)} at ${session.time}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              color: Color(
                                                                  0xFF6B6B6B),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed:
                                                      session.zoomLink != null
                                                          ? () => _joinSession(
                                                              session.zoomLink!)
                                                          : null,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue[700],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Join',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                  if (_upcomingSessions.length > 2)
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _showAllSessions =
                                                !_showAllSessions;
                                          });
                                        },
                                        child: Text(
                                          _showAllSessions
                                              ? 'Show Less'
                                              : 'Show More',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                const SizedBox(height: 32),

                // Latest Update Section
                const Text(
                  'Latest Update',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingRecordings
                    ? const Center(child: CircularProgressIndicator())
                    : _recordingsError != null
                        ? Center(child: Text(_recordingsError!))
                        : _latestRecordings.isEmpty
                            ? const Center(
                                child: Text('No recent videos found.'))
                            : Column(
                                children: _latestRecordings
                                    .map((rec) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: InkWell(
                                            onTap: () => _showVideoPlayerDialog(
                                                rec.videoUrl),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 120,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    image: rec.thumbnailUrl !=
                                                            null
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                                rec.thumbnailUrl!),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child: rec.thumbnailUrl ==
                                                          null
                                                      ? const Icon(
                                                          Icons.videocam,
                                                          size: 48,
                                                          color: Colors.grey)
                                                      : null,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        rec.name,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF1E1E1E)),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        rec.description,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black87),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .calendar_today,
                                                              size: 14,
                                                              color: Color(
                                                                  0xFF6B6B6B)),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            rec.uploadDate
                                                                .toString()
                                                                .split(' ')[0],
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xFF6B6B6B),
                                                                fontSize: 13),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.play_circle_outline,
                                                      color: Color(0xFF4788A8)),
                                                  onPressed: () =>
                                                      _showVideoPlayerDialog(
                                                          rec.videoUrl),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                const SizedBox(height: 32),

                // Exams Section
                const Text(
                  'Exams',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingMockExams
                    ? const Center(child: CircularProgressIndicator())
                    : _mockExamsError != null
                        ? Center(child: Text(_mockExamsError!))
                        : _latestMockExams.isEmpty
                            ? const Center(
                                child: Text('No mock exams available.'))
                            : Column(
                                children: _latestMockExams
                                    .map((exam) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: Card(
                                            child: ListTile(
                                              title: Text(exam.title),
                                              subtitle: Text(exam.description),
                                              trailing: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ExamScreen(
                                                              mockExam: exam),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue[700],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                                ),
                                                child: const Text('Start',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateItem(String title) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 80,
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
    return ' 27${d.inHours > 0 ? '${twoDigits(d.inHours)}:' : ''}$minutes:$seconds';
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
                      ),
                    ),
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B6B6B)),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _isPlaying ? _controller.pause() : _controller.play();
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class RecordingPlayerScreen extends StatelessWidget {
  final RecordingModel recording;
  const RecordingPlayerScreen({Key? key, required this.recording})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recording.name),
      ),
      body: Center(
        child: _VideoPlayerDialogContent(videoUrl: recording.videoUrl),
      ),
    );
  }
}
