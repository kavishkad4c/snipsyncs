import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../providers/salon_provider.dart';
import 'manage_services_screen.dart';
import 'manage_staff_screen.dart';
import 'manage_appointments_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? _selectedSalonId;

  @override
  void initState() {
    super.initState();
    // Select first salon by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedSalonId = '1'; // Default to Salon Anura
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalonProvider>(
      builder: (context, salonProvider, child) {
        final salons = salonProvider.salons;
        
        // If no salon is selected and we have salons, select the first one
        if (_selectedSalonId == null && salons.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedSalonId = salons.first.id;
            });
          });
        }
        
       final selectedSalon = _selectedSalonId != null
    ? salons.where((salon) => salon.id == _selectedSalonId).firstOrNull
    : null;
        
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
                                  selectedSalon != null ? selectedSalon.name : 'Manage your salon',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
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
                        const SizedBox(height: 24),
                        // Salon selector dropdown
                        if (salons.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedSalonId,
                              underline: const SizedBox(),
                              isExpanded: true,
                              dropdownColor: AppColors.primary,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              items: salons.map((salon) {
                                return DropdownMenuItem<String>(
                                  value: salon.id,
                                  child: Text(salon.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSalonId = value;
                                });
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
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
      },
    );
  }
}

extension on List {
  T? firstWhereOrNull<T>(bool Function(T) test) {
    for (var item in this) {
      if (test(item)) return item;
    }
    return null;
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}