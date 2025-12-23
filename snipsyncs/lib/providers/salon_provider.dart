import 'package:flutter/material.dart';
import '../models/salon_model.dart';
import '../services/supabase_service.dart';

class SalonProvider extends ChangeNotifier {
  List<SalonModel> _salons = [
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
  bool _isLoading = false;
  String? _error;

  List<SalonModel> get salons => _salons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get salonCount => _salons.length;

  SalonProvider() {
    // Load salons from database in a real implementation
    // For now, we're using default salons
  }

  Future<void> loadSalons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await SupabaseService.getSalons();
      _salons = data.map((json) => SalonModel.fromJson(json)).toList();
      
      // If no salons found, provide default salons
      if (_salons.isEmpty) {
        _salons = [
          SalonModel(
            id: 'default-1',
            name: 'Salon Anura',
            address: '123 Main Street, Colombo',
            phone: '+94 11 234 5678',
            email: 'anura@snipsyncs.com',
            description: 'Premium hair salon in Colombo',
          ),
          SalonModel(
            id: 'default-2',
            name: 'Kandy Salon',
            address: '456 Temple Road, Kandy',
            phone: '+94 81 234 5678',
            email: 'kandy@snipsyncs.com',
            description: 'Traditional barber shop in Kandy',
          ),
          SalonModel(
            id: 'default-3',
            name: 'Shire Design',
            address: '789 Hill Street, Nuwara Eliya',
            phone: '+94 52 234 5678',
            email: 'shire@snipsyncs.com',
            description: 'Modern beauty salon in Nuwara Eliya',
          ),
        ];
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading salons: $e');
      
      // Provide default salons on error
      _salons = [
        SalonModel(
          id: 'default-1',
          name: 'Salon Anura',
          address: '123 Main Street, Colombo',
          phone: '+94 11 234 5678',
          email: 'anura@snipsyncs.com',
          description: 'Premium hair salon in Colombo',
        ),
        SalonModel(
          id: 'default-2',
          name: 'Kandy Salon',
          address: '456 Temple Road, Kandy',
          phone: '+94 81 234 5678',
          email: 'kandy@snipsyncs.com',
          description: 'Traditional barber shop in Kandy',
        ),
        SalonModel(
          id: 'default-3',
          name: 'Shire Design',
          address: '789 Hill Street, Nuwara Eliya',
          phone: '+94 52 234 5678',
          email: 'shire@snipsyncs.com',
          description: 'Modern beauty salon in Nuwara Eliya',
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SalonModel?> getSalonById(String id) async {
    try {
      final data = await SupabaseService.getSalonById(id);
      if (data != null) {
        return SalonModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error getting salon by ID: $e');
    }
    return null;
  }

  SalonModel? findSalonById(String id) {
    try {
      return _salons.firstWhere((salon) => salon.id == id);
    } catch (e) {
      return null;
    }
  }
}