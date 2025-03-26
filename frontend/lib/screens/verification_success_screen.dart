import 'package:flutter/material.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Verification Completed',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 80),

            // Success Icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[50],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer circle
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green[200]!,
                        width: 2,
                      ),
                    ),
                  ),
                  // Inner circle with checkmark
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green[400],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  // Decorative dots
                  ...List.generate(4, (index) {
                    return Positioned(
                      top: index == 0 ? 20 : null,
                      bottom: index == 1 ? 20 : null,
                      left: index == 2 ? 20 : null,
                      right: index == 3 ? 20 : null,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.orange[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                  // Small green plus signs
                  ...List.generate(4, (index) {
                    return Positioned(
                      top: index == 0 ? 40 : null,
                      bottom: index == 1 ? 40 : null,
                      left: index == 2 ? 40 : null,
                      right: index == 3 ? 40 : null,
                      child: Container(
                        width: 12,
                        height: 12,
                        child: Icon(
                          Icons.add,
                          size: 12,
                          color: Colors.green[300],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 80),

            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
