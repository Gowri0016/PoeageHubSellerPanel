import 'package:flutter/material.dart';

class ReportsAnalyticsScreen extends StatelessWidget {
  static const routeName = '/reports-analytics';

  const ReportsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: const Center(child: Text('Sales, reports and analytics')),
    );
  }
}
