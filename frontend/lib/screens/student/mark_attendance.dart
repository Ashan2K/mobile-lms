import 'package:flutter/material.dart';

class MarkView extends StatefulWidget {
  const MarkView({super.key});

  @override
  State<MarkView> createState() => _MarkViewState();
}

class _MarkViewState extends State<MarkView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Mark'),
      ),
    );
  }
}
