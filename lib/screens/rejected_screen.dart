import 'package:flutter/material.dart';

class RejectedScreen extends StatelessWidget {
  static const routeName = '/rejected';

  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String reason = '';
    String rejectedAt = '';
    if (args is Map) {
      reason = (args['reason'] ?? '').toString();
      rejectedAt = (args['rejectedAt'] ?? '').toString();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Application Rejected')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.cancel, size: 96, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'We\'re sorry, your application was rejected.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (reason.isNotEmpty)
                  Text(
                    'Reason: $reason',
                    textAlign: TextAlign.center,
                  ),
                if (rejectedAt.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Date: $rejectedAt',
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
