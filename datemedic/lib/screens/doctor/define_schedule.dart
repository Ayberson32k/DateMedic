import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../models/schedule.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart'; // Para formateo de horas

class DefineScheduleScreen extends StatefulWidget {
  final String doctorId;
  final int dayOfWeek;
  final String dayName;

  const DefineScheduleScreen({
    super.key,
    required this.doctorId,
    required this.dayOfWeek,
    required this.dayName,
  });

  @override
  _DefineScheduleScreenState createState() => _DefineScheduleScreenState();
}

class _DefineScheduleScreenState extends State<DefineScheduleScreen> {
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  List<DoctorSchedule> _schedules = [];
  final AppointmentService _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await _appointmentService.getDoctorSchedulesForDay(
      widget.doctorId,
      DateTime(
        2024,
        1,
        widget.dayOfWeek,
      ), // Fecha ficticia solo para obtener el día de la semana
    );
    setState(() {
      _schedules = schedules;
    });
  }

  Future<void> _pickTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final dt = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        final format = DateFormat.jm(); // Formato 12 horas con AM/PM
        controller.text = format.format(dt);
      });
    }
  }

  void _addSchedule() async {
    if (_startTimeController.text.isEmpty || _endTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona horas de inicio y fin.'),
        ),
      );
      return;
    }

    // Convertir a formato 24 horas para guardar
    final startTime24 = DateFormat(
      'HH:mm',
    ).format(DateFormat.jm().parse(_startTimeController.text));
    final endTime24 = DateFormat(
      'HH:mm',
    ).format(DateFormat.jm().parse(_endTimeController.text));

    await _appointmentService.addDoctorSchedule(
      doctorId: widget.doctorId,
      dayOfWeek: widget.dayOfWeek,
      startTime: startTime24,
      endTime: endTime24,
    );
    _startTimeController.clear();
    _endTimeController.clear();
    _loadSchedules();
  }

  void _deleteSchedule(String scheduleId) async {
    await _appointmentService.deleteDoctorSchedule(scheduleId);
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Definir Horarios', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Horarios del día ${widget.dayName}', style: headingStyle),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(context, _startTimeController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _startTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Inicio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickTime(context, _endTimeController),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _endTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Finaliza',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time_filled),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: CustomButton(
                text: 'Agregar Horario',
                onPressed: _addSchedule,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 30),
            Text('Horarios Creados:', style: subHeadingStyle),
            const SizedBox(height: 10),
            _schedules.isEmpty
                ? const Center(
                    child: Text(
                      'No hay horarios definidos para este día.',
                      style: bodyTextStyle,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      // Convertir a formato 12 horas para mostrar
                      final displayStartTime = DateFormat.jm().format(
                        DateFormat('HH:mm').parse(schedule.startTime),
                      );
                      final displayEndTime = DateFormat.jm().format(
                        DateFormat('HH:mm').parse(schedule.endTime),
                      );

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
                                '$displayStartTime - $displayEndTime',
                                style: bodyTextStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: errorColor,
                                ),
                                onPressed: () => _deleteSchedule(schedule.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
