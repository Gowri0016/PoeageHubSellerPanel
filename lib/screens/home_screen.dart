import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'add_product_screen.dart';
import 'vendor_profile_screen.dart';
import 'product_management_screen.dart';
import 'notifications_screen.dart';
import 'order_management_screen.dart';
import 'payments_payouts_screen.dart';
import 'reports_analytics_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AuthProvider>().currentSeller;

    if (seller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // management cards to show on the home screen
    final managementItems = [
      _ManagementItem(
        Icons.person,
        'Vendor Profile',
        'Manage your profile',
        VendorProfileScreen.routeName,
      ),
      _ManagementItem(
        Icons.inventory_2,
        'Product Management',
        'Add, edit or remove products',
        ProductManagementScreen.routeName,
      ),
      _ManagementItem(
        Icons.notifications,
        'Notifications & Alerts',
        'View alerts',
        NotificationsScreen.routeName,
      ),
      _ManagementItem(
        Icons.shopping_cart,
        'Order Management',
        'View and process orders',
        OrderManagementScreen.routeName,
      ),
      _ManagementItem(
        Icons.account_balance_wallet,
        'Payment & Payouts',
        'Payment history & payouts',
        PaymentsPayoutsScreen.routeName,
      ),
      _ManagementItem(
        Icons.bar_chart,
        'Reports & Analytics',
        'Sales & performance',
        ReportsAnalyticsScreen.routeName,
      ),
      _ManagementItem(
        Icons.support_agent,
        'Support',
        'Contact support',
        SupportScreen.routeName,
      ),
      _ManagementItem(
        Icons.settings,
        'Settings',
        'App settings',
        SettingsScreen.routeName,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(seller.businessName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                // determine columns based on width
                final crossAxisCount = constraints.maxWidth > 800
                    ? 4
                    : constraints.maxWidth > 600
                    ? 3
                    : 2;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: managementItems.map((item) {
                    return _ManagementCard(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      onTap: () {
                        if (item.routeName != null) {
                          Navigator.of(context).pushNamed(item.routeName!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.title} tapped')),
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            // Products section removed as requested
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddProductScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ManagementItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? routeName;

  _ManagementItem(this.icon, this.title, this.subtitle, [this.routeName]);
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
