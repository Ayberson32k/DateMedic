import 'package:datemedic/models/medical_center.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; // Asegúrate de añadir uuid a tu pubspec.yaml
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService = StorageService();
  static const Uuid _uuid = Uuid();

  // Guarda la sesión del usuario actual
  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserType', user.userType);
    await prefs.setString('currentUserId', user.id);
  }

  // Carga la sesión del usuario actual
  Future<Map<String, String>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('currentUserType');
    final userId = prefs.getString('currentUserId');
    if (userType != null && userId != null) {
      return {'userType': userType, 'userId': userId};
    }
    return null;
  }

  // Cierra la sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserType');
    await prefs.remove('currentUserId');
  }

  Future<User?> login(String email, String password) async {
    final user = await _storageService.getUser(email, password);
    if (user != null) {
      await _saveSession(user);
      return user;
    }
    return null;
  }

  Future<User?> registerPatient({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String phone,
    required String address,
    String? profileImageUrl,
  }) async {
    // Verificar si el correo ya existe
    final existingUser = await _storageService.getUserByEmail(email);
    if (existingUser != null) {
      return null; // El correo ya está en uso
    }

    final newUser = User(
      id: _uuid.v4(),
      email: email,
      password: password,
      name: name,
      userType: 'patient',
      dob: dob,
      phone: phone,
      address: address,
      profileImageUrl: profileImageUrl,
    );
    await _storageService.insertUser(newUser);
    await _saveSession(newUser);
    return newUser;
  }

  Future<User?> registerDoctor({
    required String clinicName,
    required String doctorName,
    required String phone,
    required String address,
    required String email,
    required String password,
    required double latitude,
    required double longitude,
    String? profileImageUrl,
  }) async {
    // Verificar si el correo ya existe
    final existingUser = await _storageService.getUserByEmail(email);
    if (existingUser != null) {
      return null; // El correo ya está en uso
    }

    final newUser = User(
      id: _uuid.v4(),
      email: email,
      password: password,
      name: doctorName, // El nombre principal del usuario es el del doctor
      userType: 'doctor',
      clinicName: clinicName,
      doctorName: doctorName,
      clinicPhone: phone,
      clinicAddress: address,
      latitude: latitude,
      longitude: longitude,
      profileImageUrl: profileImageUrl,
    );
    await _storageService.insertUser(newUser);

    // También creamos un MedicalCenter asociado al doctor
    final newMedicalCenter = MedicalCenter(
      id: _uuid.v4(),
      name: clinicName,
      doctorId: newUser.id,
      doctorName: doctorName,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      imageUrl: profileImageUrl, // Reutilizamos la imagen de perfil del doctor
    );
    await _storageService.insertMedicalCenter(newMedicalCenter);

    await _saveSession(newUser);
    return newUser;
  }
}
