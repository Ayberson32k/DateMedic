import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/appointment_card.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../utils/helpers.dart';
import 'appointment_details_doctor.dart';

class CompletedAppointmentsScreen extends StatefulWidget {
  final String doctorId;

  const CompletedAppointmentsScreen({super.key, required this.doctorId});

  @override
  _CompletedAppointmentsScreenState createState() =>
      _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState
    extends State<CompletedAppointmentsScreen> {
  List<Appointment> _completedAppointments = [];
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadCompletedAppointments();
  }

  Future<void> _loadCompletedAppointments() async {
    final appointments = await _appointmentService
        .getDoctorCompletedAppointments(widget.doctorId);
    setState(() {
      // Ordenar por fecha de la más reciente a la más antigua
      _completedAppointments = appointments
        ..sort(
          (a, b) => b.appointmentDateTime.compareTo(a.appointmentDateTime),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Atendidas', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCompletedAppointments,
        child: _completedAppointments.isEmpty
            ? const Center(
                child: Text(
                  'Aún no tienes citas atendidas.',
                  style: bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _completedAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = _completedAppointments[index];
                  return AppointmentCard(
                    appointment: appointment,
                    showPatientDetails: true,
                    actionButton: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorAppointmentDetailsScreen(
                                  appointment: appointment,
                                  isViewingDetails: true,
                                ),
                          ),
                        );
                      },
                      child: const Text('Detalles de atención'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
