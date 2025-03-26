import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../components/custom_app_bar.dart';

class FeesView extends StatelessWidget {
  const FeesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fees',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Use this QR code to enter the\nPhysical class',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: 'https://your-qr-code-data-here',
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Due payment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentTable(
                [
                  ['23', 'OL', 'January', true],
                  ['23', 'PH', 'January', true],
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentHistoryTable(
                [
                  ['23', 'OL', 'December', '24/12/10'],
                  ['23', 'PH', 'December', '24/12/10'],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTable(List<List<dynamic>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Batch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Month',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rows.map((row) => _buildPaymentRow(row)),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTable(List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Batch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Month',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...rows.map((row) => _buildHistoryRow(row)),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(List<dynamic> rowData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  rowData[0],
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  rowData[1],
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  rowData[2],
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Pay'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildHistoryRow(List<String> rowData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  rowData[0],
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  rowData[1],
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  rowData[2],
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  rowData[3],
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
