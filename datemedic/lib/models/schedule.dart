class DoctorSchedule {
  final String id;
  final String doctorId;
  final int dayOfWeek; // 1 = Lunes, 7 = Domingo
  final String startTime; 
  final String endTime; 

  DoctorSchedule({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory DoctorSchedule.fromMap(Map<String, dynamic> map) {
    return DoctorSchedule(
      id: map['id'],
      doctorId: map['doctorId'],
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}
