import 'package:flutter/material.dart';

class PaymentsPayoutsScreen extends StatelessWidget {
  static const routeName = '/payments-payouts';

  const PaymentsPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments & Payouts')),
      body: const Center(child: Text('Payment history and payout details')),
    );
  }
}
