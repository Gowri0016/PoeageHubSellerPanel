import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  static const routeName = '/support';

  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: const Center(child: Text('Support and contact options')),
    );
  }
}
