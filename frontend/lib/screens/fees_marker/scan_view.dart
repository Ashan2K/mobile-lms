import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:frontend/screens/fees_marker/scan_result_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/screens/fees_marker/permission_view.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  MobileScannerController? controller;
  bool isScanning = true;
  bool _isInitialized = false;
  bool _hasPermission = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInitialize();
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
        await _initializeCamera();
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

  Future<void> _initializeCamera() async {
    try {
      if (controller != null) {
        return; // Camera is already initialized
      }

      controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      await controller?.start();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    controller?.stop();
    controller?.dispose();
    super.dispose();
  }

  void _handleScanResult(String code) {
    controller?.stop();
    setState(() {
      isScanning = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultView(
          qrCode: code,
          onScanAnother: () {
            Navigator.pop(context);
            if (controller != null) {
              controller?.start();
            } else {
              _initializeCamera();
            }
            setState(() {
              isScanning = true;
            });
          },
          onDone: () {
            Navigator.pop(context); // Pop ScanResultView
            Navigator.pop(context); // Pop ScanView
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building ScanView with _hasPermission: $_hasPermission');

    if (!_hasPermission) {
      print('Showing PermissionView');
      return PermissionView(
        onPermissionGranted: () async {
          print('Permission granted callback');
          setState(() {
            _hasPermission = true;
          });
          await _initializeCamera();
        },
        errorMessage: _errorMessage,
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller!,
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
                      isScanning ? 'Scanning...' : 'Scan paused',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScanResultView(
                                qrCode: "123456789", // Example QR code
                                onScanAnother: () {
                                  Navigator.pop(context);
                                  if (controller != null) {
                                    controller?.start();
                                  } else {
                                    _initializeCamera();
                                  }
                                  setState(() {
                                    isScanning = true;
                                  });
                                },
                                onDone: () {
                                  Navigator.pop(context); // Pop ScanResultView
                                  Navigator.pop(context); // Pop ScanView
                                },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Scan Result'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
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
