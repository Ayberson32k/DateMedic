import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/appointment_card.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../utils/helpers.dart'; // Para formateo de fechas
import 'appointment_details_doctor.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  final String doctorId;

  const PendingAppointmentsScreen({super.key, required this.doctorId});

  @override
  _PendingAppointmentsScreenState createState() =>
      _PendingAppointmentsScreenState();
}

class _PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  List<Appointment> _pendingAppointments = [];
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadPendingAppointments();
  }

  Future<void> _loadPendingAppointments() async {
    final appointments = await _appointmentService.getDoctorPendingAppointments(
      widget.doctorId,
    );
    setState(() {
      _pendingAppointments = appointments
        ..sort(
          (a, b) => a.appointmentDateTime.compareTo(b.appointmentDateTime),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas por Atender', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPendingAppointments,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Citas de Hoy', style: headingStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Pacientes Citados: ${DateHelper.formatDate(DateTime.now())}',
                    style: subHeadingStyle.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _pendingAppointments.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes citas pendientes para hoy.',
                        style: bodyTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pendingAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _pendingAppointments[index];
                        return AppointmentCard(
                          appointment: appointment,
                          showPatientDetails:
                              true, // Mostrar nombre e imagen del paciente
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
                              _loadPendingAppointments(); // Recargar al regresar
                            },
                            child: const Text('Atender'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
