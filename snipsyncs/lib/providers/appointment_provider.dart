import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/appointment_model.dart';

class AppointmentProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAppointments({String? userId, String? salonId, String? staffId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await SupabaseService.getAppointments(userId: userId, salonId: salonId, staffId: staffId);
      _appointments = data.map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStaffAppointments(String staffId, String salonId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await SupabaseService.getStaffAppointments(staffId, salonId);
      _appointments = data.map((json) => AppointmentModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment({
    required String serviceId,
    required DateTime appointmentDate,
    required String notes,
    String? salonId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await SupabaseService.createAppointment(
        serviceId: serviceId,
        appointmentDate: appointmentDate,
        notes: notes,
        salonId: salonId,
      );

      final newAppointment = AppointmentModel.fromJson(data);
      _appointments.insert(0, newAppointment);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      await SupabaseService.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
      );

      // Update local state
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(status: status);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}