import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/appointment_card.dart';
import '../../models/user.dart';
import '../../models/appointment.dart';
import '../../services/storage_service.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart'; // Para el logout
import '../../utils/helpers.dart'; // Para formateo de fechas
import 'centers_list.dart';
import 'appointment_history.dart';
import '../profile_selection.dart'; // Para volver a la selección de perfil
import 'dart:io'; // Para FileImage

class PatientHomeScreen extends StatefulWidget {
  final String patientId;

  const PatientHomeScreen({super.key, required this.patientId});

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  User? _patientUser;
  List<Appointment> _upcomingAppointments = [];
  final StorageService _storageService = StorageService();
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    final user = await _storageService.getUserById(widget.patientId);
    final upcoming = await _appointmentService.getPatientUpcomingAppointments(
      widget.patientId,
    );
    setState(() {
      _patientUser = user;
      _upcomingAppointments = upcoming;
    });
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ProfileSelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Paciente', style: appTitleStyle),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _patientUser == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPatientData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subdivisión 1: Información de perfil
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  _patientUser!.profileImageUrl != null
                                  ? FileImage(
                                      File(_patientUser!.profileImageUrl!),
                                    )
                                  : null,
                              child: _patientUser!.profileImageUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey[700],
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_patientUser!.name, style: headingStyle),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _patientUser!.phone ?? 'N/A',
                                      style: bodyTextStyle,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _patientUser!.address ?? 'N/A',
                                      style: bodyTextStyle,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _patientUser!.dob ?? 'N/A',
                                      style: bodyTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Subdivisión 2: Botones de acción
                    Center(
                      child: Column(
                        children: [
                          CustomButton(
                            text: 'Crear una cita',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CentersListScreen(
                                    patientId: widget.patientId,
                                  ),
                                ),
                              );
                              _loadPatientData(); // Recargar datos al regresar
                            },
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          const SizedBox(height: 15),
                          CustomButton(
                            text: 'Historial Citas',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentHistoryScreen(
                                        patientId: widget.patientId,
                                      ),
                                ),
                              );
                            },
                            color: accentColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Subdivisión 3: Próxima Cita
                    Text('Próxima Cita', style: headingStyle),
                    const SizedBox(height: 15),
                    _upcomingAppointments.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'No hay citas próximas, intenta crear una nueva cita.',
                                style: bodyTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _upcomingAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _upcomingAppointments[index];
                              return AppointmentCard(
                                appointment: appointment,
                                // No hay botón de acción en esta vista según la descripción
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
