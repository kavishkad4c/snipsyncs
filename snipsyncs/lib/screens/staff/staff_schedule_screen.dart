
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../utils/colors.dart';

class StaffScheduleScreen extends StatelessWidget {
  const StaffScheduleScreen({super.key});

@override
Widget build(BuildContext context) {
  final appointments = [
    AppointmentModel(
      id: '1',
      userId: 'c1',
      customerName: 'John Doe',
      serviceId: 's1',
      serviceName: 'Premium Haircut',
      staffId: 'staff1',
      staffName: 'Staff One',  // Add this
      appointmentDate: DateTime.now(),
      status: 'confirmed',  // Add this
      notes: '',  // Add this if required
    ),
    AppointmentModel(
      id: '2',
      userId: 'c2',
      customerName: 'Jane Smith',
      serviceId: 's2',
      serviceName: 'Hair Coloring',
      staffId: 'staff1',
      staffName: 'Staff One',  // Add this
      appointmentDate: DateTime.now().add(Duration(hours: 2)),
      status: 'pending',  // Add this
      notes: '',  // Add this if required
    ),
  ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                               appointment.serviceName ?? '',  // Added null check
                              style: const TextStyle(
                             fontSize: 14,
                          color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              appointment.serviceName ?? '',  // Added null safety operator
                      style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(appointment.appointmentDate),  // Changed from dateTime
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        '${appointment.duration} min',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.secondary),
                          ),
                          child: const Text('View Details'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                          ),
                          child: const Text('Start Service'),
                        ),
                      ),
                    ],
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