import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../providers/appointment_provider.dart';
import 'staff_schedule_screen.dart';
import 'staff_queue_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _StaffDashboard(),
    StaffScheduleScreen(),
    StaffQueueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.secondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'Queue'),
        ],
      ),
    );
  }
}

class _StaffDashboard extends StatefulWidget {
  const _StaffDashboard();

  @override
  State<_StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<_StaffDashboard> {
  @override
  void initState() {
    super.initState();
    // Load appointments when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser != null) {
        appointmentProvider.loadAppointments(userId: authService.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    
    final userName = authService.currentUser?.userMetadata?['full_name'] as String? ?? 'Staff Member';
    
    // Filter today's appointments
    final today = DateTime.now();
    final todayAppointments = appointmentProvider.appointments.where((appointment) {
      final appointmentDate = appointment.appointmentDate;
      return appointmentDate.year == today.year &&
             appointmentDate.month == today.month &&
             appointmentDate.day == today.day;
    }).toList();
    
    // Filter appointments in queue
    final queueAppointments = todayAppointments.where((apt) => apt.status == 'pending').length;
    
    // Calculate summary
    final totalAppointments = todayAppointments.length;
    final completedAppointments = todayAppointments.where((apt) => apt.status == 'completed').length;
    final inProgressAppointments = todayAppointments.where((apt) => apt.status == 'in_progress').length;
    final remainingAppointments = totalAppointments - completedAppointments - inProgressAppointments;
    
    // Get next appointment
    final upcomingAppointments = todayAppointments
        .where((apt) => apt.appointmentDate.isAfter(DateTime.now()))
        .toList()
          ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    final nextAppointment = upcomingAppointments.isNotEmpty ? upcomingAppointments.first : null;

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
                  gradient: AppColors.gradient2,
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
                              'Welcome Back,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                          child: const Icon(Icons.notifications_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _DashboardCard(
                            title: 'Today',
                            value: totalAppointments.toString(),
                            subtitle: 'Appointments',
                            icon: Icons.event,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DashboardCard(
                            title: 'Queue',
                            value: queueAppointments.toString(),
                            subtitle: 'Waiting',
                            icon: Icons.people,
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
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            title: 'View Schedule',
                            icon: Icons.calendar_month,
                            color: AppColors.primary,
                            onTap: () {
                              // Navigate to schedule screen
                              final state = context.findAncestorStateOfType<_StaffHomeScreenState>();
                              state?.setState(() => state._selectedIndex = 1);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            title: 'Manage Queue',
                            icon: Icons.list,
                            color: AppColors.accent,
                            onTap: () {
                              // Navigate to queue screen
                              final state = context.findAncestorStateOfType<_StaffHomeScreenState>();
                              state?.setState(() => state._selectedIndex = 2);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Next Appointment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    nextAppointment != null 
                        ? _NextAppointmentCard(appointment: nextAppointment)
                        : const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No upcoming appointments today'),
                            ),
                          ),
                    const SizedBox(height: 24),
                    const Text(
                      'Today\'s Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(title: 'Total Appointments', value: totalAppointments.toString()),
                          const Divider(height: 24),
                          _SummaryRow(title: 'Completed', value: completedAppointments.toString()),
                          const Divider(height: 24),
                          _SummaryRow(title: 'In Progress', value: inProgressAppointments.toString()),
                          const Divider(height: 24),
                          _SummaryRow(title: 'Remaining', value: remainingAppointments.toString()),
                        ],
                      ),
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

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _DashboardCard({
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
              fontSize: 32,
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

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final dynamic appointment;

  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradient1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.customerName ?? 'Customer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.serviceName ?? 'Service',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${appointment.appointmentDate.hour}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')} - '
                  '${appointment.appointmentDate.add(Duration(minutes: appointment.duration ?? 45)).hour}:'
                  '${appointment.appointmentDate.add(Duration(minutes: appointment.duration ?? 45)).minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Start appointment action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}