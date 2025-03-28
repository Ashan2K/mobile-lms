import 'package:flutter/material.dart';

class FeesView extends StatefulWidget {
  const FeesView({Key? key}) : super(key: key);

  @override
  State<FeesView> createState() => _FeesViewState();
}

class _FeesViewState extends State<FeesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fees",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Text('Fees View - Coming Soon'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add fee record functionality
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
