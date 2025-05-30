import 'package:flutter/material.dart';
import 'dart:io';

import '../../utils/constants.dart';
import '../../services/storage_service.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../profile_selection.dart';

import 'schedule_management.dart';
import 'pending_appointments.dart';
import 'upcoming_appointments.dart';
import 'completed_appointments.dart';

import 'package:url_launcher/url_launcher.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorId;

  const DoctorHomeScreen({super.key, required this.doctorId});

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final StorageService _storageService = StorageService();
  User? _doctor;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  Future<void> _loadDoctorInfo() async {
    final user = await _storageService.getUserById(widget.doctorId);
    setState(() {
      _doctor = user;
    });
  }

  void _openMap() async {
    if (_doctor == null) return;

    final lat = _doctor!.latitude;
    final lng = _doctor!.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_doctor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Médico', style: appTitleStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileSelectionScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _doctor!.profileImageUrl != null
                      ? FileImage(File(_doctor!.profileImageUrl!))
                      : null,
                  child: _doctor!.profileImageUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_doctor!.clinicName ?? '', style: headingStyle),
                      Text(
                        'Dr(a). ${_doctor!.doctorName}',
                        style: subHeadingStyle,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Expanded(child: Text(_doctor!.clinicAddress ?? '')),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16),
                          const SizedBox(width: 4),
                          Text(_doctor!.clinicPhone ?? ''),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.map, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Lat: ${_doctor!.latitude?.toStringAsFixed(4)}, Lng: ${_doctor!.longitude?.toStringAsFixed(4)}',
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            tooltip: 'Abrir en Google Maps',
                            onPressed: _openMap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Botones de navegación
            CustomButton(
              text: 'Días y horarios de atención',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ScheduleManagementScreen(doctorId: _doctor!.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: 'Citas por atender',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PendingAppointmentsScreen(doctorId: _doctor!.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: 'Citas futuras',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UpcomingAppointmentsScreen(doctorId: _doctor!.id),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            CustomButton(
              text: 'Citas atendidas',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CompletedAppointmentsScreen(doctorId: _doctor!.id),
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
