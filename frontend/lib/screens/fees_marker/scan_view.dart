import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:frontend/screens/fees_marker/scan_result_view.dart';
import 'package:frontend/screens/fees_marker/permission_view.dart';
import 'package:frontend/screens/fees_marker/course_selection_dialog.dart';
import 'package:frontend/screens/fees_marker/student_profile_view.dart';
import 'package:frontend/models/course_model.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> with WidgetsBindingObserver {
  bool isScanning = true;
  bool _hasPermission = false;
  String _errorMessage = '';
  CourseModel? _selectedCourse;
  bool _hasShownCourseDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Show course selection dialog only once when dependencies change
    if (_selectedCourse == null && !_hasShownCourseDialog) {
      _hasShownCourseDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCourseSelectionDialog();
      });
    }
  }

  @override
  void dispose() {
    print('Disposing ScanView');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('App lifecycle state changed to: $state');
    // No need to manually manage camera lifecycle with MobileScanner widget
  }

  void _showCourseSelectionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CourseSelectionDialog(
        onCourseSelected: (CourseModel course) {
          if (mounted) {
            setState(() {
              _selectedCourse = course;
            });
            _checkPermissionAndInitialize();
          }
        },
      ),
    ).then((_) {
      // If dialog is dismissed without selecting a course, go back
      if (mounted && _selectedCourse == null) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _checkPermissionAndInitialize() async {
    try {
      final status = await Permission.camera.request();
      print('Camera permission status: $status');

      if (status.isGranted) {
        print('Camera permission is granted');
        setState(() {
          _hasPermission = true;
        });
      } else {
        print('Camera permission is not granted');
        setState(() {
          _hasPermission = false;
        });
      }
    } catch (e) {
      print('Error checking permissions: $e');
      setState(() {
        _errorMessage = 'Error checking permissions: $e';
      });
    }
  }

  void _handleScanResult(String code) {
    print('Handling scan result: $code');
    setState(() {
      isScanning = false;
    });

    // Navigate to student profile view with the scanned student ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileView(
          studentId: code,
          selectedCourse: _selectedCourse!,
        ),
      ),
    ).then((_) {
      // Restart scanning when returning from student profile
      _restartScanning();
    });
  }

  void _restartScanning() {
    setState(() {
      isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building ScanView with _hasPermission: $_hasPermission, mounted: $mounted');

    if (!_hasPermission) {
      print('Showing PermissionView');
      return PermissionView(
        onPermissionGranted: () async {
          print('Permission granted callback');
          setState(() {
            _hasPermission = true;
          });
        },
        errorMessage: _errorMessage,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_selectedCourse != null)
            IconButton(
              onPressed: _showCourseSelectionDialog,
              icon: const Icon(Icons.school),
              tooltip: 'Change Course',
            ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  _handleScanResult(code);
                }
              }
            },
          ),

          // Course Info Display
          if (_selectedCourse != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCourse!.courseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _selectedCourse!.courseCode,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Scanning frame overlay
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Scanning status indicator and buttons
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isScanning ? 'Scan student QR code' : 'Scan paused',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Point camera at student QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
