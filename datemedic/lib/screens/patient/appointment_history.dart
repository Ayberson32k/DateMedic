import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../utils/helpers.dart'; // Para formateo de fechas
import 'appointment_details_patient.dart'; // Para ver detalles
import 'centers_list.dart'; // Para "Nueva Cita"

class AppointmentHistoryScreen extends StatefulWidget {
  final String patientId;

  const AppointmentHistoryScreen({super.key, required this.patientId});

  @override
  _AppointmentHistoryScreenState createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  List<Appointment> _appointmentHistory = [];
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadAppointmentHistory();
  }

  Future<void> _loadAppointmentHistory() async {
    final history = await _appointmentService.getPatientAppointmentHistory(
      widget.patientId,
    );
    setState(() {
      // Ordenar por fecha de la más reciente a la más antigua
      _appointmentHistory = history
        ..sort(
          (a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Citas', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointmentHistory,
        child: _appointmentHistory.isEmpty
            ? const Center(
                child: Text(
                  'Aún no tienes citas en tu historial.',
                  style: bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _appointmentHistory.length,
                itemBuilder: (context, index) {
                  final appointment = _appointmentHistory[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha: ${DateHelper.formatDate(appointment.appointmentDateTime)}',
                            style: subHeadingStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clínica: ${appointment.medicalCenterName}',
                            style: bodyTextStyle,
                          ),
                          Text(
                            'Dr(a).: ${appointment.doctorName}',
                            style: bodyTextStyle,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientAppointmentDetailsScreen(
                                          appointment: appointment,
                                        ),
                                  ),
                                );
                              },
                              child: const Text('Detalles de consulta'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
