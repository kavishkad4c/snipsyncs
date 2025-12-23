import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'add_staff_screen.dart';

class ManageStaffScreen extends StatelessWidget {
  const ManageStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = [
      {'name': 'Sarah Johnson', 'specialty': 'Hair Stylist', 'rating': '4.9'},
      {'name': 'Emily Davis', 'specialty': 'Colorist', 'rating': '4.8'},
      {'name': 'Michael Brown', 'specialty': 'Barber', 'rating': '4.7'},
      {'name': 'Jessica Wilson', 'specialty': 'Nail Technician', 'rating': '4.9'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Staff'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffScreen()),
          );
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staff.length,
        itemBuilder: (context, index) {
          final member = staff[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.accent.withOpacity(0.2),
                child: Text(
                  member['name']![0],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
              title: Text(
                member['name']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(member['specialty']!),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        member['rating']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // Navigate to edit
                  } else if (value == 'schedule') {
                    // Navigate to schedule
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'schedule',
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 20),
                        SizedBox(width: 8),
                        Text('Manage Schedule'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}