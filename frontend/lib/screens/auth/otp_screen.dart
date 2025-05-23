import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'verification_success_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;

  const OtpScreen({Key? key, required this.phoneNumber, required this.userId})
      : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  String currentText = "";
  bool isLoading = false;
  int _timer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    try {
      await (AuthService.sendOtp(widget.phoneNumber));
    } catch (e) {
      debugPrint('Error sending OTP: $e');
    }
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_timer > 0) {
          setState(() {
            _timer--;
          });
          startTimer();
        } else {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  void resendOtp() {
    if (_canResend) {
      setState(() {
        _timer = 60;
        _canResend = false;
        isLoading = true;
      });
      // TODO: Implement resend OTP logic
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  void verifyOtp() async {
    if (currentText.length == 6) {
      setState(() {
        isLoading = true;
      });
      await AuthService.verifyOtp(
          widget.phoneNumber, currentText, widget.userId);
      setState(() {
        isLoading = false;
      });
      // Navigate to the next screen if OTP verification is successful
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo section
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.35,
                    child: Image.asset('lib/images/koreanlogo.png'),
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome text
                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 4-digit code sent to\n${widget.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // OTP Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 55,
                      fieldWidth: 55,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      activeColor: Colors.blue[700]!,
                      inactiveColor: Colors.grey[300]!,
                      selectedColor: Colors.blue[700]!,
                      errorBorderColor: Colors.red,
                      disabledColor: Colors.grey[300]!,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: textEditingController,
                    onCompleted: (v) {
                      setState(() {
                        currentText = v;
                      });
                      verifyOtp();
                    },
                    onChanged: (value) {
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      return true;
                    },
                    showCursor: false,
                    keyboardType: TextInputType.number,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Timer and Resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Resend code in $_timer seconds',
                      style: TextStyle(
                        color:
                            _canResend ? Colors.blue[700] : Color(0xFF666666),
                      ),
                    ),
                    if (_canResend) ...[
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: resendOtp,
                        child: Text(
                          'Resend',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 32),

                // Verify Button
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: currentText.length == 6 ? verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //textEditingController.dispose();
    super.dispose();
  }
}
