import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../models/medical_center.dart';
import '../../services/storage_service.dart';
import 'schedule_list.dart'; // Para ir a la lista de horarios
import 'dart:io'; // Para FileImage

class CentersListScreen extends StatefulWidget {
  final String patientId;

  const CentersListScreen({super.key, required this.patientId});

  @override
  _CentersListScreenState createState() => _CentersListScreenState();
}

class _CentersListScreenState extends State<CentersListScreen> {
  List<MedicalCenter> _medicalCenters = [];
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadMedicalCenters();
  }

  Future<void> _loadMedicalCenters() async {
    final centers = await _storageService.getAllMedicalCenters();
    setState(() {
      _medicalCenters = centers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centros Médicos Disponibles', style: appTitleStyle),
        backgroundColor: primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMedicalCenters,
        child: _medicalCenters.isEmpty
            ? const Center(
                child: Text(
                  'No hay centros médicos disponibles en este momento.',
                  style: bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _medicalCenters.length,
                itemBuilder: (context, index) {
                  final center = _medicalCenters[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleListScreen(
                            patientId: widget.patientId,
                            medicalCenter: center,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: center.imageUrl != null
                                  ? FileImage(File(center.imageUrl!))
                                  : null,
                              child: center.imageUrl == null
                                  ? Icon(
                                      Icons.local_hospital,
                                      size: 35,
                                      color: Colors.grey[700],
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(center.name, style: subHeadingStyle),
                                  Text(
                                    'Dr(a). ${center.doctorName}',
                                    style: bodyTextStyle,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.phone,
                                          color: primaryColor,
                                        ),
                                        onPressed: () {
                                          // Implementar llamada telefónica
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Llamando a ${center.phone}',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.message,
                                          color: primaryColor,
                                        ),
                                        onPressed: () {
                                          // Implementar envío de mensaje
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Enviando mensaje a ${center.phone}',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.map,
                                          color: primaryColor,
                                        ),
                                        onPressed: () {
                                          // Implementar apertura de mapa
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Abriendo mapa de ${center.address}',
                                              ),
                                            ),
                                          );
                                        },
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
                  );
                },
              ),
      ),
    );
  }
}
