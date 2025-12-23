import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/customer/customer_dashboard.dart';
import '../screens/admin/enhanced_admin_dashboard.dart';
import '../screens/staff/enhanced_staff_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show loading while checking auth state
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If not logged in, show login screen
        if (!authService.isLoggedIn) {
          return const LoginScreen();
        }

        // Route based on user role
        if (authService.userRole == 'admin') {
          return const EnhancedAdminDashboard();
        } else if (authService.userRole == 'staff') {
          return const EnhancedStaffDashboard();
        } else {
          return const CustomerDashboard();
        }
      },
    );
  }
}