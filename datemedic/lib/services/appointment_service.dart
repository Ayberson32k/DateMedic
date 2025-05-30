import 'package:uuid/uuid.dart';
import '../models/appointment.dart';
import '../models/schedule.dart';
import 'storage_service.dart';

class AppointmentService {
  final StorageService _storageService = StorageService();
  static const Uuid _uuid = Uuid();

  Future<void> createAppointment({
    required String patientId,
    required String doctorId,
    required String medicalCenterName,
    required String doctorName,
    required DateTime appointmentDateTime,
  }) async {
    final appointmentCode = _uuid
        .v4()
        .substring(0, 8)
        .toUpperCase(); // Genera un código único
    final newAppointment = Appointment(
      id: _uuid.v4(),
      patientId: patientId,
      doctorId: doctorId,
      medicalCenterName: medicalCenterName,
      doctorName: doctorName,
      appointmentDateTime: appointmentDateTime,
      appointmentCode: appointmentCode,
      status: 'pending',
    );
    await _storageService.insertAppointment(newAppointment);
  }

  Future<List<Appointment>> getPatientUpcomingAppointments(
    String patientId,
  ) async {
    final allAppointments = await _storageService.getPatientAppointments(
      patientId,
    );
    final now = DateTime.now();
    return allAppointments
        .where(
          (a) => a.appointmentDateTime.isAfter(now) && a.status == 'pending',
        )
        .toList();
  }

  Future<List<Appointment>> getPatientAppointmentHistory(
    String patientId,
  ) async {
    final allAppointments = await _storageService.getPatientAppointments(
      patientId,
    );
    return allAppointments
        .where(
          (a) =>
              a.status == 'completed' ||
              a.appointmentDateTime.isBefore(DateTime.now()),
        ) // Incluir citas pasadas y completadas
        .toList();
  }

  Future<List<Appointment>> getDoctorPendingAppointments(
    String doctorId,
  ) async {
    final allAppointments = await _storageService.getDoctorAppointments(
      doctorId,
    );
    final today = DateTime.now();
    return allAppointments
        .where(
          (a) =>
              a.appointmentDateTime.year == today.year &&
              a.appointmentDateTime.month == today.month &&
              a.appointmentDateTime.day == today.day &&
              a.status == 'pending',
        )
        .toList();
  }

  Future<List<Appointment>> getDoctorUpcomingAppointments(
    String doctorId,
  ) async {
    final allAppointments = await _storageService.getDoctorAppointments(
      doctorId,
    );
    final today = DateTime.now();
    return allAppointments
        .where(
          (a) => a.appointmentDateTime.isAfter(today) && a.status == 'pending',
        )
        .toList();
  }

  Future<List<Appointment>> getDoctorCompletedAppointments(
    String doctorId,
  ) async {
    final allAppointments = await _storageService.getDoctorAppointments(
      doctorId,
    );
    return allAppointments.where((a) => a.status == 'completed').toList();
  }

  Future<void> updateAppointmentDetails(
    Appointment appointment, {
    String? diagnosis,
    String? prescription,
    String? status,
  }) async {
    final updatedAppointment = Appointment(
      id: appointment.id,
      patientId: appointment.patientId,
      doctorId: appointment.doctorId,
      medicalCenterName: appointment.medicalCenterName,
      doctorName: appointment.doctorName,
      appointmentDateTime: appointment.appointmentDateTime,
      appointmentCode: appointment.appointmentCode,
      status: status ?? appointment.status,
      diagnosis: diagnosis ?? appointment.diagnosis,
      prescription: prescription ?? appointment.prescription,
    );
    await _storageService.updateAppointment(updatedAppointment);
  }

  // Métodos para Horarios del Doctor
  Future<void> addDoctorSchedule({
    required String doctorId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final newSchedule = DoctorSchedule(
      id: _uuid.v4(),
      doctorId: doctorId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    await _storageService.insertDoctorSchedule(newSchedule);
  }

  Future<List<DoctorSchedule>> getDoctorSchedules(String doctorId) {
    return _storageService.getDoctorSchedules(doctorId);
  }

  Future<List<DoctorSchedule>> getDoctorSchedulesForDay(
    String doctorId,
    DateTime date,
  ) {
    // Obtener el día de la semana (1 = Lunes, 7 = Domingo)
    // DateTime.monday es 1, DateTime.sunday es 7
    final dayOfWeek = date.weekday;
    return _storageService.getDoctorSchedulesByDay(doctorId, dayOfWeek);
  }

  Future<void> deleteDoctorSchedule(String scheduleId) async {
    await _storageService.deleteDoctorSchedule(scheduleId);
  }

  // Método para obtener los horarios disponibles para una fecha específica en un centro médico
  Future<List<DateTime>> getAvailableSlots({
    required String medicalCenterId,
    required DateTime date,
  }) async {
    final medicalCenter = await _storageService.getMedicalCenterById(
      medicalCenterId,
    );
    if (medicalCenter == null) return [];

    final doctorSchedules = await getDoctorSchedulesForDay(
      medicalCenter.doctorId,
      date,
    );
    final doctorAppointments = await _storageService.getDoctorAppointments(
      medicalCenter.doctorId,
    );

    final List<DateTime> availableSlots = [];
    final selectedDate = DateTime(date.year, date.month, date.day);

    for (var schedule in doctorSchedules) {
      final startHour = int.parse(schedule.startTime.split(':')[0]);
      final startMinute = int.parse(schedule.startTime.split(':')[1]);
      final endHour = int.parse(schedule.endTime.split(':')[0]);
      final endMinute = int.parse(schedule.endTime.split(':')[1]);

      final scheduleStart = selectedDate.add(
        Duration(hours: startHour, minutes: startMinute),
      );
      final scheduleEnd = selectedDate.add(
        Duration(hours: endHour, minutes: endMinute),
      );

      // Asumiendo citas de 30 minutos, puedes ajustar esto
      for (
        var slotTime = scheduleStart;
        slotTime.isBefore(scheduleEnd);
        slotTime = slotTime.add(const Duration(minutes: 30))
      ) {
        bool isBooked = false;
        for (var appointment in doctorAppointments) {
          if (appointment.appointmentDateTime.year == slotTime.year &&
              appointment.appointmentDateTime.month == slotTime.month &&
              appointment.appointmentDateTime.day == slotTime.day &&
              appointment.appointmentDateTime.hour == slotTime.hour &&
              appointment.appointmentDateTime.minute == slotTime.minute &&
              appointment.status == 'pending') {
            isBooked = true;
            break;
          }
        }
        if (!isBooked && slotTime.isAfter(DateTime.now())) {
          // Solo mostrar horarios futuros y no ocupados
          availableSlots.add(slotTime);
        }
      }
    }
    return availableSlots;
  }
}
