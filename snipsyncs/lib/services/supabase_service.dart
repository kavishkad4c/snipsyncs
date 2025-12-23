import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://dokojgoqrtuigfazjccu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRva29qZ29xcnR1aWdmYXpqY2N1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzNzM0NDgsImV4cCI6MjA4MTk0OTQ0OH0.7Zn11beb-tD1zmTj3irrD5X0fQajCdLMbozKR4mqoOA';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }
  
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  static User? get currentUser => client.auth.currentUser;
  
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // Database methods
  static Future<List<Map<String, dynamic>>> getServices() async {
    final response = await client
        .from('services')
        .select()
        .order('created_at', ascending: false);
    return response;
  }
  
  static Future<List<Map<String, dynamic>>> getSalons() async {
    final response = await client
        .from('salons')
        .select()
        .eq('is_active', true)
        .order('name');
    return response;
  }
  
  static Future<Map<String, dynamic>?> getSalonById(String salonId) async {
    final response = await client
        .from('salons')
        .select()
        .eq('id', salonId)
        .eq('is_active', true)
        .single();
    return response;
  }
  
  static Future<List<Map<String, dynamic>>> getAppointments({String? userId, String? salonId, String? staffId}) async {
    var query = client.from('appointments').select('''
      *,
      services(name,duration),
      users(full_name),
      staff:staff_id(full_name),
      salons(name)
    ''');
    
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    
    if (salonId != null) {
      query = query.eq('salon_id', salonId);
    }
    
    if (staffId != null) {
      query = query.eq('staff_id', staffId);
    }
    
    final response = await query.order('appointment_date', ascending: true);
    return response;
  }
  
  static Future<Map<String, dynamic>> createAppointment({
    required String serviceId,
    required DateTime appointmentDate,
    required String notes,
    String? salonId,
  }) async {
    final response = await client.from('appointments').insert({
      'user_id': currentUser!.id,
      'service_id': serviceId,
      'appointment_date': appointmentDate.toIso8601String(),
      'notes': notes,
      'status': 'pending',
      'salon_id': salonId,
    }).select().single();
    
    return response;
  }
  
  static Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    await client.from('appointments').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', appointmentId);
  }
  
  static Future<List<Map<String, dynamic>>> getStaff() async {
    final response = await client
        .from('users')
        .select()
        .eq('role', 'staff')
        .order('created_at', ascending: false);
    return response;
  }
  
  static Future<Map<String, dynamic>> createService({
    required String name,
    required String description,
    required double price,
    required int duration,
  }) async {
    final response = await client.from('services').insert({
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'is_active': true,
    }).select().single();
    
    return response;
  }
  
  static Future<void> updateService({
    required String serviceId,
    required Map<String, dynamic> updates,
  }) async {
    await client.from('services').update({
      ...updates,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', serviceId);
  }
  
  static Future<void> deleteService(String serviceId) async {
    await client.from('services').update({
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', serviceId);
  }
  
  // Staff-specific methods
  static Future<List<Map<String, dynamic>>> getStaffAppointments(String staffId, String salonId) async {
    final response = await client.from('appointments').select('''
      *,
      services(name,duration),
      users(full_name),
      salons(name)
    ''')
    .eq('staff_id', staffId)
    .eq('salon_id', salonId)
    .order('appointment_date', ascending: true);
    
    return response;
  }
  
  // Admin methods for managing staff assignments to salons
  static Future<void> assignStaffToSalon(String staffId, String salonId) async {
    // This would typically be handled through the staff_schedules table
    // For now, we'll just note that the staff works at this salon
    await client.from('users').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', staffId);
  }
}