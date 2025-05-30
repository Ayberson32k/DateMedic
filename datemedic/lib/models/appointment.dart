class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String medicalCenterName;
  final String doctorName;
  final DateTime appointmentDateTime;
  final String appointmentCode;
  String status; // 'pending', 'completed', 'cancelled'
  String? diagnosis;
  String? prescription;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.medicalCenterName,
    required this.doctorName,
    required this.appointmentDateTime,
    required this.appointmentCode,
    this.status = 'pending',
    this.diagnosis,
    this.prescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'medicalCenterName': medicalCenterName,
      'doctorName': doctorName,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'appointmentCode': appointmentCode,
      'status': status,
      'diagnosis': diagnosis,
      'prescription': prescription,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      medicalCenterName: map['medicalCenterName'],
      doctorName: map['doctorName'],
      appointmentDateTime: DateTime.parse(map['appointmentDateTime']),
      appointmentCode: map['appointmentCode'],
      status: map['status'],
      diagnosis: map['diagnosis'],
      prescription: map['prescription'],
    );
  }
}
