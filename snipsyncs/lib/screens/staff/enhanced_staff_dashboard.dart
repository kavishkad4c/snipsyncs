import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../providers/appointment_provider.dart';

class EnhancedStaffDashboard extends StatefulWidget {
  const EnhancedStaffDashboard({super.key});

  @override
  State<EnhancedStaffDashboard> createState() => _EnhancedStaffDashboardState();
}

class _EnhancedStaffDashboardState extends State<EnhancedStaffDashboard> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load appointments when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStaffAppointments();
    });
  }

  Future<void> _loadStaffAppointments() async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.currentUser != null) {
      // Determine which salon this staff member belongs to
      String? salonId;
      final email = authService.currentUser?.email ?? '';
      
      // Assign staff to salons based on email pattern
      if (email.contains('anura')) {
        salonId = '1'; // Salon Anura
      } else if (email.contains('kandy')) {
        salonId = '2'; // Kandy Salon
      } else if (email.contains('shire')) {
        salonId = '3'; // Shire Design
      } else {
        // Default to Salon Anura for demo staff
        salonId = '1';
      }
      
      // Load appointments for this staff member at their assigned salon
      await appointmentProvider.loadStaffAppointments(authService.currentUser!.id, salonId);
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    
    final userName = authService.currentUser?.userMetadata?['full_name'] as String? ?? 'Staff Member';
    
    // Determine which salon this staff member belongs to
    String? salonId;
    String salonName = 'Salon Anura';
    final email = authService.currentUser?.email ?? '';
    
    if (email.contains('anura')) {
      salonId = '1';
      salonName = 'Salon Anura';
    } else if (email.contains('kandy')) {
      salonId = '2';
      salonName = 'Kandy Salon';
    } else if (email.contains('shire')) {
      salonId = '3';
      salonName = 'Shire Design';
    } else {
      // Default to Salon Anura for demo staff
      salonId = '1';
      salonName = 'Salon Anura';
    }
    
    // Filter appointments for selected date and salon
    final selectedDateAppointments = appointmentProvider.appointments.where((appointment) {
      final appointmentDate = appointment.appointmentDate;
      final isCorrectDate = appointmentDate.year == _selectedDate.year &&
             appointmentDate.month == _selectedDate.month &&
             appointmentDate.day == _selectedDate.day;
      
      return isCorrectDate;
    }).toList();
    
    // Sort appointments by time
    selectedDateAppointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    
    // Calculate statistics
    final totalAppointments = selectedDateAppointments.length;
    final completedAppointments = selectedDateAppointments.where((apt) => apt.status == 'completed').length;
    final pendingAppointments = selectedDateAppointments.where((apt) => apt.status == 'pending').length;
    final inProgressAppointments = selectedDateAppointments.where((apt) => apt.status == 'in_progress').length;
    
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
                            Text(
                              salonName,
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
                              child: const Icon(Icons.notifications_outlined, color: Colors.white),
                            ),
                          ],
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
                            title: 'Pending',
                            value: pendingAppointments.toString(),
                            subtitle: 'In Queue',
                            icon: Icons.access_time,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Appointments',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadStaffAppointments,
                          tooltip: 'Refresh Appointments',
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (appointmentProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (appointmentProvider.error != null)
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Error: ${appointmentProvider.error}',
                              style: const TextStyle(color: AppColors.error),
                            ),
                            ElevatedButton(
                              onPressed: _loadStaffAppointments,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (selectedDateAppointments.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'No appointments scheduled for this day',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: (selectedDateAppointments.length * 190.0) + 50.0, // Increased height per card + buffer
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: selectedDateAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = selectedDateAppointments[index];
                            return _AppointmentCard(
                              appointment: appointment,
                              onUpdateStatus: (newStatus) {
                                _updateAppointmentStatus(appointment.id, newStatus);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
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
                            title: 'Update Queue',
                            icon: Icons.update,
                            color: AppColors.primary,
                            onTap: () {
                              // TODO: Implement queue update functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Queue update functionality coming soon')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            title: 'Manage Customers',
                            icon: Icons.group,
                            color: AppColors.secondary,
                            onTap: () {
                              // TODO: Implement customer management
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Customer management coming soon')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Day Summary',
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
                          _SummaryRow(title: 'Pending', value: pendingAppointments.toString()),
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

  Future<void> _updateAppointmentStatus(String appointmentId, String newStatus) async {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final success = await appointmentProvider.updateAppointmentStatus(
      appointmentId: appointmentId,
      status: newStatus,
    );
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment status updated to $newStatus'),
          backgroundColor: AppColors.success,
        ),
      );
      // Reload appointments to reflect the change
      _loadStaffAppointments();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update appointment status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

class _AppointmentCard extends StatelessWidget {
  final dynamic appointment;
  final Function(String) onUpdateStatus;

  const _AppointmentCard({
    required this.appointment,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(appointment.status);
    final statusText = _getStatusText(appointment.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appointment.customerName ?? 'Customer',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.content_cut, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                appointment.serviceName ?? 'Service',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '${appointment.appointmentDate.hour}:${appointment.appointmentDate.minute.toString().padLeft(2, '0')} - '
                '${appointment.appointmentDate.add(Duration(minutes: appointment.duration ?? 45)).hour}:'
                '${appointment.appointmentDate.add(Duration(minutes: appointment.duration ?? 45)).minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (appointment.status == 'pending')
                ElevatedButton(
                  onPressed: () => onUpdateStatus('in_progress'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Service'),
                ),
              if (appointment.status == 'in_progress')
                ElevatedButton(
                  onPressed: () => onUpdateStatus('completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
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