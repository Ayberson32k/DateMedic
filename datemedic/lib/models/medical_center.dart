class MedicalCenter {
  final String id;
  final String name;
  final String doctorId; // ID del doctor asociado a este centro
  final String doctorName;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl; // Imagen del centro/doctor

  MedicalCenter({
    required this.id,
    required this.name,
    required this.doctorId,
    required this.doctorName,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };
  }

  factory MedicalCenter.fromMap(Map<String, dynamic> map) {
    return MedicalCenter(
      id: map['id'],
      name: map['name'],
      doctorId: map['doctorId'],
      doctorName: map['doctorName'],
      phone: map['phone'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      imageUrl: map['imageUrl'],
    );
  }
}
