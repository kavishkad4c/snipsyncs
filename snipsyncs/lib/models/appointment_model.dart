class AppointmentModel {
  final String id;
  final String userId;
  final String? customerName;
  final String serviceId;
  final String? serviceName;
  final String? staffId;
  final String? staffName;
  final DateTime appointmentDate;
  final String status; // 'pending', 'confirmed', 'in_progress', 'completed', 'cancelled'
  final double? totalAmount;
  final int? duration;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    required this.id,
    required this.userId,
    this.customerName,
    required this.serviceId,
    this.serviceName,
    this.staffId,
    this.staffName,
    required this.appointmentDate,
    required this.status,
    this.totalAmount,
    this.duration,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      userId: json['user_id'],
      customerName: json['users']?['full_name'],
      serviceId: json['service_id'],
      serviceName: json['services']?['name'],
      staffId: json['staff_id'],
      staffName: json['staff']?['full_name'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      status: json['status'],
      totalAmount: json['total_amount']?.toDouble(),
      duration: json['services']?['duration'],
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'staff_id': staffId,
      'appointment_date': appointmentDate.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'notes': notes,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? serviceId,
    String? serviceName,
    String? staffId,
    String? staffName,
    DateTime? appointmentDate,
    String? status,
    double? totalAmount,
    int? duration,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}