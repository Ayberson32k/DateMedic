

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; 
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_image.dart';
import '../../services/auth_service.dart';
import 'home_doctor.dart';
import 'package:datemedic/screens/maps/location_picker_screen.dart'; 

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({Key? key}) : super(key: key);

  @override
  _RegisterDoctorScreenState createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _profileImageUrl;
  LatLng? _selectedLocation; // Para la ubicación en el mapa
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _clinicNameController.dispose();
    _doctorNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_clinicNameController.text.isEmpty ||
        _doctorNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos y selecciona una ubicación.')),
      );
      return;
    }

    try {
      final user = await _authService.registerDoctor(
        clinicName: _clinicNameController.text,
        doctorName: _doctorNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        email: _emailController.text,
        password: _passwordController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        profileImageUrl: _profileImageUrl,
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta de médico creada exitosamente!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorHomeScreen(doctorId: user.id)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la cuenta. El correo ya está en uso.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  void _openMapPicker() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(

          initialLocation: _selectedLocation,
        ),
      ),
    );

    // Si se recibió un resultado válido del mapa
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLocation = LatLng(result['latitude'], result['longitude']);
        // Actualizar el campo de dirección con la dirección devuelta por el mapa
        _addressController.text = result['address'] ?? 'Dirección no disponible';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DateMedic', style: appTitleStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileImagePicker(
                onImageSelected: (path) {
                  setState(() {
                    _profileImageUrl = path;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _clinicNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Clínica',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Médico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Número de Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
             
              TextField(
                controller: _addressController,
                readOnly: true, 
                onTap: _openMapPicker, // Al tocarlo, abre el mapa
                decoration: const InputDecoration(
                  labelText: 'Dirección (Toca para seleccionar en el mapa)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  suffixIcon: Icon(Icons.map), 
                ),
              ),
              const SizedBox(height: 15),
              CustomButton(
                text: _selectedLocation == null
                    ? 'Abrir Mapa y Ubicar Clínica'
                    : 'Ubicación Seleccionada',
                onPressed: _openMapPicker,
                color: _selectedLocation == null ? primaryColor : accentColor,
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: smallTextStyle,
                  ),
                ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: 'Crear Usuario',
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}