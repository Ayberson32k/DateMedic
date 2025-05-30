import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'define_schedule.dart';

class ScheduleManagementScreen extends StatelessWidget {
  final String doctorId;

  const ScheduleManagementScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Días de Atención', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 7, // Lunes a Domingo
        itemBuilder: (context, index) {
          // DateTime.monday es 1, DateTime.sunday es 7
          final dayOfWeek = index + 1;
          final dayName = DateHelper.getDayName(dayOfWeek);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dayName, style: subHeadingStyle),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DefineScheduleScreen(
                            doctorId: doctorId,
                            dayOfWeek: dayOfWeek,
                            dayName: dayName,
                          ),
                        ),
                      );
                    },
                    child: const Text('Horarios'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
