import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/appointment.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';
import 'centers_list.dart';
import 'appointment_history.dart';

class PatientAppointmentDetailsScreen extends StatelessWidget {
  final Appointment appointment;

  const PatientAppointmentDetailsScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Consulta', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre de la Clínica: ${appointment.medicalCenterName}',
              style: headingStyle,
            ),
            const SizedBox(height: 10),
            Text(
              'Nombre del Médico: ${appointment.doctorName}',
              style: subHeadingStyle,
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha de Consulta: ${DateHelper.formatDateTime(appointment.appointmentDateTime)}',
              style: bodyTextStyle,
            ),
            const Divider(height: 30, thickness: 1),
            Text('Diagnóstico Realizado:', style: subHeadingStyle),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appointment.diagnosis ?? 'Diagnóstico no disponible',
                style: bodyTextStyle,
              ),
            ),
            const SizedBox(height: 20),
            Text('Receta:', style: subHeadingStyle),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                appointment.prescription ?? 'Receta no disponible',
                style: bodyTextStyle,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Nueva Cita',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CentersListScreen(
                            patientId: appointment.patientId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CustomButton(
                    text: 'Historial',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentHistoryScreen(
                            patientId: appointment.patientId,
                          ),
                        ),
                      );
                    },
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
