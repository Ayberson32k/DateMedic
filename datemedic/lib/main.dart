import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para controlar la orientación
import 'screens/profile_selection.dart';
import 'screens/patient/home_patient.dart';
import 'screens/doctor/home_doctor.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Forzar orientación vertical para una mejor experiencia móvil
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  Widget _initialScreen =
      const CircularProgressIndicator(); // Pantalla de carga

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final session = await _authService.loadSession();
    if (session != null) {
      if (session['userType'] == 'patient') {
        setState(() {
          _initialScreen = PatientHomeScreen(patientId: session['userId']!);
        });
      } else if (session['userType'] == 'doctor') {
        setState(() {
          _initialScreen = DoctorHomeScreen(doctorId: session['userId']!);
        });
      }
    } else {
      setState(() {
        _initialScreen = const ProfileSelectionScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateMedic Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: primaryColor,
        hintColor: accentColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // Color del botón
            foregroundColor: Colors.white, // Color del texto del botón
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
      ),
      home: _initialScreen,
    );
  }
}
 