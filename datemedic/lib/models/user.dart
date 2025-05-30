class User {
  final String id;
  final String email;
  final String password; 
  final String name;
  final String userType; // 'patient' o 'doctor'

  // Datos específicos del paciente
  final String? dob; // Fecha de nacimiento
  final String? phone;
  final String? address;
  final String? profileImageUrl;

  // Datos específicos del doctor
  final String? clinicName;
  final String?
  doctorName; 
  final String? clinicPhone;
  final String? clinicAddress;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.userType,
    this.dob,
    this.phone,
    this.address,
    this.profileImageUrl,
    this.clinicName,
    this.doctorName,
    this.clinicPhone,
    this.clinicAddress,
    this.latitude,
    this.longitude,
  });

  // Convertir un User a un Mapa (para guardar en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'userType': userType,
      'dob': dob,
      'phone': phone,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'clinicName': clinicName,
      'doctorName': doctorName,
      'clinicPhone': clinicPhone,
      'clinicAddress': clinicAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Crear un User desde un Mapa (al leer de la base de datos)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      userType: map['userType'],
      dob: map['dob'],
      phone: map['phone'],
      address: map['address'],
      profileImageUrl: map['profileImageUrl'],
      clinicName: map['clinicName'],
      doctorName: map['doctorName'],
      clinicPhone: map['clinicPhone'],
      clinicAddress: map['clinicAddress'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
