import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../utils/colors.dart';
import '../../widgets/appointment_card.dart';
import 'appointment_history_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<AppointmentModel> _upcomingAppointments = [
    AppointmentModel(
      id: '1',
      userId: 'c1',
      customerName: 'John Doe',
      serviceId: 's1',
      serviceName: 'Premium Haircut',
      staffId: 'staff1',
      staffName: 'Sarah Johnson',
      appointmentDate: DateTime.now().add(const Duration(days: 2, hours: 10)),
      status: 'confirmed',
      totalAmount: 25.00,
      duration: 45,
    ),
    AppointmentModel(
      id: '2',
      userId: 'c1',
      customerName: 'John Doe',
      serviceId: 's2',
      serviceName: 'Hair Coloring',
      staffId: 'staff2',
      staffName: 'Emily Davis',
      appointmentDate: DateTime.now().add(const Duration(days: 5, hours: 14)),
      status: 'confirmed',
      totalAmount: 80.00,
      duration: 120,
    ),
  ];

  void _cancelAppointment(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _upcomingAppointments = _upcomingAppointments
                    .where((a) => a.id != appointmentId)
                    .toList();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppointmentHistoryScreen()),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
            label: const Text('History', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _upcomingAppointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No upcoming appointments',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book a service to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _upcomingAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = _upcomingAppointments[index];
                  return AppointmentCard(
                    appointment: appointment,
                    onCancel: () => _cancelAppointment(appointment.id),
                  );
                },
              ),
            ),
    );
  }
}