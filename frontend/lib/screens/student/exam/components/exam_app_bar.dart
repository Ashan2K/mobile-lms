import 'package:flutter/material.dart';

class ExamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentQuestionIndex;
  final VoidCallback onClose;

  const ExamAppBar({
    Key? key,
    required this.currentQuestionIndex,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black87),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit Exam?'),
              content: const Text(
                  'Are you sure you want to exit the exam? Your progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    onClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                  ),
                  child:
                      const Text('Exit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: const Text(
              'EPS-TOPIK MOCK EXAM',
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: currentQuestionIndex < 20
                  ? Colors.blue[100]
                  : Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentQuestionIndex < 20 ? 'P1' : 'P2',
                  style: TextStyle(
                    color: currentQuestionIndex < 20
                        ? Colors.blue[700]
                        : Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  currentQuestionIndex < 20 ? '1-20' : '21-40',
                  style: TextStyle(
                    color: currentQuestionIndex < 20
                        ? Colors.blue[700]
                        : Colors.orange[700],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
