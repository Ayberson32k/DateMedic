import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/appointment.dart';
import '../../models/user.dart'; // Para obtener los datos del paciente
import '../../services/appointment_service.dart';
import '../../services/storage_service.dart'; // Para obtener datos del paciente
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';
import 'dart:io'; // Para FileImage

class DoctorAppointmentDetailsScreen extends StatefulWidget {
  final Appointment appointment;
  final bool isViewingDetails; // Para saber si solo estamos viendo o atendiendo

  const DoctorAppointmentDetailsScreen({
    super.key,
    required this.appointment,
    this.isViewingDetails = false,
  });

  @override
  _DoctorAppointmentDetailsScreenState createState() =>
      _DoctorAppointmentDetailsScreenState();
}

class _DoctorAppointmentDetailsScreenState
    extends State<DoctorAppointmentDetailsScreen> {
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final AppointmentService _appointmentService = AppointmentService();
  final StorageService _storageService = StorageService();
  User? _patient;

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
    if (widget.isViewingDetails) {
      // Si solo estamos viendo detalles, cargar los datos existentes
      _diagnosisController.text = widget.appointment.diagnosis ?? '';
      _prescriptionController.text = widget.appointment.prescription ?? '';
    }
  }

  Future<void> _loadPatientDetails() async {
    final patient = await _storageService.getUserById(
      widget.appointment.patientId,
    );
    setState(() {
      _patient = patient;
    });
  }

  void _saveAppointmentDetails() async {
    if (_diagnosisController.text.isEmpty ||
        _prescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa el diagnóstico y la receta.'),
        ),
      );
      return;
    }

    // Actualizar la cita a "completed"
    await _appointmentService.updateAppointmentDetails(
      widget.appointment,
      diagnosis: _diagnosisController.text,
      prescription: _prescriptionController.text,
      status: 'completed',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detalles de atención guardados.')),
    );
    Navigator.pop(context); // Regresar a la pantalla anterior
  }

  void _cancelAndClear() {
    _diagnosisController.clear();
    _prescriptionController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos eliminados. No se guardó la consulta.'),
      ),
    );
    Navigator.pop(context); // Regresar a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Atención', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: _patient == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del paciente
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: _patient!.profileImageUrl != null
                                ? FileImage(File(_patient!.profileImageUrl!))
                                : null,
                            child: _patient!.profileImageUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey[700],
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_patient!.name, style: headingStyle),
                                const SizedBox(height: 5),
                                Text(
                                  'Código de Cita: ${widget.appointment.appointmentCode}',
                                  style: subHeadingStyle,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Fecha: ${DateHelper.formatDate(widget.appointment.appointmentDateTime)}',
                                  style: bodyTextStyle,
                                ),
                                Text(
                                  'Hora: ${DateHelper.formatTime(widget.appointment.appointmentDateTime)}',
                                  style: bodyTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text('Detalles de Atención', style: headingStyle),
                  const SizedBox(height: 20),

                  Text('Diagnóstico Realizado:', style: subHeadingStyle),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _diagnosisController,
                    maxLines: 5,
                    readOnly: widget
                        .isViewingDetails, // Deshabilitar edición si solo se está viendo
                    decoration: const InputDecoration(
                      hintText: 'Ingrese el diagnóstico...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Receta:', style: subHeadingStyle),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _prescriptionController,
                    maxLines: 10,
                    readOnly: widget
                        .isViewingDetails, // Deshabilitar edición si solo se está viendo
                    decoration: const InputDecoration(
                      hintText: 'Ingrese la receta médica...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (!widget
                      .isViewingDetails) // Mostrar botones de acción solo si se está atendiendo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Enviar',
                            onPressed: _saveAppointmentDetails,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomButton(
                            text: 'Eliminar',
                            onPressed: _cancelAndClear,
                            color: errorColor,
                          ),
                        ),
                      ],
                    ),
                  if (widget
                      .isViewingDetails) // Botón de regresar si solo se está viendo
                    Center(
                      child: CustomButton(
                        text: 'Regresar',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
