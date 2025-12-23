import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/service_model.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadServices() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await SupabaseService.getServices();
      _services = data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createService({
    required String name,
    required String description,
    required double price,
    required int duration,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await SupabaseService.createService(
        name: name,
        description: description,
        price: price,
        duration: duration,
      );

      final newService = ServiceModel.fromJson(data);
      _services.insert(0, newService);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService({
    required String serviceId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await SupabaseService.updateService(
        serviceId: serviceId,
        updates: updates,
      );

      // Update local state
      final index = _services.indexWhere((service) => service.id == serviceId);
      if (index != -1) {
        // Reload services to get updated data
        await loadServices();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      await SupabaseService.deleteService(serviceId);

      // Remove from local state
      _services.removeWhere((service) => service.id == serviceId);
      notifyListeners();

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