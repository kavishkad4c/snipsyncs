import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import 'customer_home_screen.dart'; // Your existing screen

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnipSyncs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(authService.currentUser?.email ?? 'User'),
                  subtitle: Text('Role: ${authService.userRole ?? 'customer'}'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () async {
                  await authService.signOut();
                },
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: const CustomerHomeScreen(), // Use your existing screen
    );
  }
}