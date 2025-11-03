import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/waiting_approval_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/vendor_profile_screen.dart';
import 'screens/product_management_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/order_management_screen.dart';
import 'screens/payments_payouts_screen.dart';
import 'screens/reports_analytics_screen.dart';
import 'screens/support_screen.dart';
import 'screens/settings_screen.dart';
import 'models/product.dart';
import 'screens/rejected_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Seller Panel',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/waiting': (context) => const WaitingApprovalScreen(),
          '/rejected': (context) => const RejectedScreen(),
          '/home': (context) => const HomeScreen(),
          '/add-product': (context) => const AddProductScreen(),
          '/edit-product': (context) => AddProductScreen(
            product: ModalRoute.of(context)!.settings.arguments as Product,
          ),
          // management screens
          VendorProfileScreen.routeName: (context) =>
              const VendorProfileScreen(),
          ProductManagementScreen.routeName: (context) =>
              const ProductManagementScreen(),
          NotificationsScreen.routeName: (context) =>
              const NotificationsScreen(),
          OrderManagementScreen.routeName: (context) =>
              const OrderManagementScreen(),
          PaymentsPayoutsScreen.routeName: (context) =>
              const PaymentsPayoutsScreen(),
          ReportsAnalyticsScreen.routeName: (context) =>
              const ReportsAnalyticsScreen(),
          SupportScreen.routeName: (context) => const SupportScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
