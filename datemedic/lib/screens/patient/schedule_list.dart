import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/medical_center.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart'; // Para formateo de fechas
import 'home_patient.dart'; // Para regresar al inicio
import 'dart:io'; // Para FileImage

class ScheduleListScreen extends StatefulWidget {
  final String patientId;
  final MedicalCenter medicalCenter;

  const ScheduleListScreen({
    super.key,
    required this.patientId,
    required this.medicalCenter,
  });

  @override
  _ScheduleListScreenState createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  DateTime _selectedDate = DateTime.now().add(
    const Duration(days: 1),
  ); // Por defecto, día siguiente
  List<DateTime> _availableSlots = [];
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    final slots = await _appointmentService.getAvailableSlots(
      medicalCenterId: widget.medicalCenter.id,
      date: _selectedDate,
    );
    setState(() {
      _availableSlots = slots;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailableSlots();
    }
  }

  void _createAppointment(DateTime slotTime) async {
    await _appointmentService.createAppointment(
      patientId: widget.patientId,
      doctorId: widget.medicalCenter.doctorId,
      medicalCenterName: widget.medicalCenter.name,
      doctorName: widget.medicalCenter.doctorName,
      appointmentDateTime: slotTime,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cita creada exitosamente!')));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PatientHomeScreen(patientId: widget.patientId),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios Disponibles', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la clínica seleccionada
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.medicalCenter.imageUrl != null
                          ? FileImage(File(widget.medicalCenter.imageUrl!))
                          : null,
                      child: widget.medicalCenter.imageUrl == null
                          ? Icon(
                              Icons.local_hospital,
                              size: 30,
                              color: Colors.grey[700],
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.medicalCenter.name,
                            style: subHeadingStyle,
                          ),
                          Text(
                            'Dr(a). ${widget.medicalCenter.doctorName}',
                            style: bodyTextStyle,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.phone,
                                  color: primaryColor,
                                ),
                                onPressed: () {}, // Implementar llamada
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.message,
                                  color: primaryColor,
                                ),
                                onPressed: () {}, // Implementar mensaje
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.map,
                                  color: primaryColor,
                                ),
                                onPressed: () {}, // Implementar mapa
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: primaryColor,
                    size: 30,
                  ),
                  onPressed: () => _selectDate(context),
                ),
                const SizedBox(width: 10),
                Text(
                  DateHelper.formatDate(_selectedDate),
                  style: headingStyle.copyWith(color: primaryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Horarios Disponibles', style: headingStyle),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _availableSlots.isEmpty
                ? const Center(
                    child: Text(
                      'No hay horarios disponibles para la fecha seleccionada.',
                      style: bodyTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _availableSlots[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateHelper.formatTime(slot),
                                style: bodyTextStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CustomButton(
                                text: 'Crear Cita',
                                onPressed: () => _createAppointment(slot),
                                color: accentColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                fontSize: 14,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
