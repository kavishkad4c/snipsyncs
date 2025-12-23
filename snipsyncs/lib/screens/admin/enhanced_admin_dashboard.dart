import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../models/salon_model.dart';
import '../../services/auth_service.dart';
import 'manage_services_screen.dart';
import 'manage_staff_screen.dart';
import 'manage_appointments_screen.dart';
import 'reports_screen.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard> {
  String? _selectedSalonId;

  @override
  void initState() {
    super.initState();
    // Will set the salon ID from auth service after build
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Set the salon ID based on the authenticated admin
    if (authService.demoSalonId != null && _selectedSalonId != authService.demoSalonId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedSalonId = authService.demoSalonId;
        });
      });
    } else if (_selectedSalonId == null) {
      // Default to first salon if none selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedSalonId = '1'; // Default to Salon Anura
        });
      });
    }
    
    // Use default salons
    final salons = [
      SalonModel(
        id: '1',
        name: 'Salon Anura',
        address: '123 Main Street, Colombo',
        phone: '+94 11 234 5678',
        email: 'anura@snipsyncs.com',
        description: 'Premium hair salon in Colombo',
      ),
      SalonModel(
        id: '2',
        name: 'Kandy Salon',
        address: '456 Temple Road, Kandy',
        phone: '+94 81 234 5678',
        email: 'kandy@snipsyncs.com',
        description: 'Traditional barber shop in Kandy',
      ),
      SalonModel(
        id: '3',
        name: 'Shire Design',
        address: '789 Hill Street, Nuwara Eliya',
        phone: '+94 52 234 5678',
        email: 'shire@snipsyncs.com',
        description: 'Modern beauty salon in Nuwara Eliya',
      ),
    ];
    
    final selectedSalon = salons.firstWhere((salon) => salon.id == _selectedSalonId, orElse: () => salons.first);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppColors.gradient3,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              selectedSalon.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: _logout,
                              tooltip: 'Logout',
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.settings, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Today',
                            value: '24',
                            subtitle: 'Appointments',
                            icon: Icons.event,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Revenue',
                            value: '\$1.2K',
                            subtitle: 'Today',
                            icon: Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ManagementCard(
                      title: 'Manage Services',
                      subtitle: 'Add, edit, or remove services',
                      icon: Icons.content_cut,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageServicesScreen()),
                        );
                      },
                    ),
                    _ManagementCard(
                      title: 'Manage Staff',
                      subtitle: 'Add staff and set schedules',
                      icon: Icons.people,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageStaffScreen()),
                        );
                      },
                    ),
                    _ManagementCard(
                      title: 'Appointments',
                      subtitle: 'View and manage all appointments',
                      icon: Icons.calendar_today,
                      color: AppColors.accent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageAppointmentsScreen()),
                        );
                      },
                    ),
                    _ManagementCard(
                      title: 'Customers',
                      subtitle: 'View and manage customer accounts',
                      icon: Icons.group,
                      color: AppColors.info,
                      onTap: () {
                        // TODO: Implement customer management screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Customer management coming soon')),
                        );
                      },
                    ),
                    _ManagementCard(
                      title: 'Reports',
                      subtitle: 'View business analytics',
                      icon: Icons.analytics,
                      color: AppColors.success,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReportsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Icon(icon, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}