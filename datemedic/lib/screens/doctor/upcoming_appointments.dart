import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/appointment_card.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../utils/helpers.dart';
import 'appointment_details_doctor.dart';

class UpcomingAppointmentsScreen extends StatefulWidget {
  final String doctorId;

  const UpcomingAppointmentsScreen({super.key, required this.doctorId});

  @override
  _UpcomingAppointmentsScreenState createState() =>
      _UpcomingAppointmentsScreenState();
}

class _UpcomingAppointmentsScreenState
    extends State<UpcomingAppointmentsScreen> {
  List<Appointment> _upcomingAppointments = [];
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadUpcomingAppointments();
  }

  Future<void> _loadUpcomingAppointments() async {
    final appointments = await _appointmentService
        .getDoctorUpcomingAppointments(widget.doctorId);
    setState(() {
      // Agrupar por fecha
      _upcomingAppointments = appointments
        ..sort(
          (a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Próximas', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadUpcomingAppointments,
        child: _upcomingAppointments.isEmpty
            ? const Center(
                child: Text(
                  'No tienes citas futuras programadas.',
                  style: bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _upcomingAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = _upcomingAppointments[index];
                  // Puedes añadir un encabezado de fecha si quieres agrupar por fecha
                  // Por simplicidad, solo mostramos la tarjeta de cita aquí
                  return AppointmentCard(
                    appointment: appointment,
                    showPatientDetails: true,
                    actionButton: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorAppointmentDetailsScreen(
                                  appointment: appointment,
                                ),
                          ),
                        );
                        _loadUpcomingAppointments(); // Recargar al regresar
                      },
                      child: const Text('Atender'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
