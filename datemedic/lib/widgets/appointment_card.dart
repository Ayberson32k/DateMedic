import 'dart:io';

import 'package:datemedic/models/user.dart';
import 'package:datemedic/services/storage_service.dart';
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Widget? actionButton;
  final bool
  showPatientDetails; // Para diferenciar entre vista de paciente y doctor

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.actionButton,
    this.showPatientDetails =
        false, // Por defecto, no muestra detalles del paciente
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateHelper.formatDate(appointment.appointmentDateTime)} - ${DateHelper.formatTime(appointment.appointmentDateTime)}',
                  style: subHeadingStyle.copyWith(color: primaryColor),
                ),
                Text(
                  'Cód: ${appointment.appointmentCode}',
                  style: smallTextStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Clínica: ${appointment.medicalCenterName}',
              style: bodyTextStyle,
            ),
            Text('Dr(a).: ${appointment.doctorName}', style: bodyTextStyle),
            if (showPatientDetails) // Mostrar solo si es para la vista del doctor
              FutureBuilder<User?>(
                future: StorageService().getUserById(appointment.patientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Paciente: Desconocido');
                  }
                  final patient = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: patient.profileImageUrl != null
                              ? FileImage(File(patient.profileImageUrl!))
                              : null,
                          child: patient.profileImageUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text('Paciente: ${patient.name}', style: bodyTextStyle),
                      ],
                    ),
                  );
                },
              ),
            if (actionButton != null) ...[
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actionButton!),
            ],
          ],
        ),
      ),
    );
  }
}
