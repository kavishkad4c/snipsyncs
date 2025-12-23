import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../utils/colors.dart';
import '../../widgets/appointment_card.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pastAppointments = [
      AppointmentModel(
        id: 'h1',
        userId: 'c1',
        customerName: 'John Doe',
        serviceId: 's1',
        serviceName: 'Premium Haircut',
        staffId: 'staff1',
        staffName: 'Sarah Johnson',
        appointmentDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'completed',
        totalAmount: 25.00,
        duration: 45,
      ),
      AppointmentModel(
        id: 'h2',
        userId: 'c1',
        customerName: 'John Doe',
        serviceId: 's3',
        serviceName: 'Hair Styling',
        staffId: 'staff3',
        staffName: 'Michael Brown',
        appointmentDate: DateTime.now().subtract(const Duration(days: 45)),
        status: 'completed',
        totalAmount: 35.00,
        duration: 60,
      ),
      AppointmentModel(
        id: 'h3',
        userId: 'c1',
        customerName: 'John Doe',
        serviceId: 's5',
        serviceName: 'Manicure & Pedicure',
        staffId: 'staff4',
        staffName: 'Jessica Wilson',
        appointmentDate: DateTime.now().subtract(const Duration(days: 60)),
        status: 'completed',
        totalAmount: 30.00,
        duration: 60,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointment History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastAppointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(appointment: pastAppointments[index]);
        },
      ),
    );
  }
}