import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/appointment.dart';
import '../models/medical_center.dart';
import '../models/schedule.dart';

class StorageService {
  static Database? _database;
  static const String _databaseName = 'datemedic_db.db';
  static const int _databaseVersion = 1;

  // Tablas
  static const String _usersTable = 'users';
  static const String _appointmentsTable = 'appointments';
  static const String _medicalCentersTable = 'medical_centers';
  static const String _doctorSchedulesTable = 'doctor_schedules';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de Usuarios
    await db.execute('''
      CREATE TABLE $_usersTable(
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        password TEXT,
        name TEXT,
        userType TEXT,
        dob TEXT,
        phone TEXT,
        address TEXT,
        profileImageUrl TEXT,
        clinicName TEXT,
        doctorName TEXT,
        clinicPhone TEXT,
        clinicAddress TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    // Crear tabla de Citas
    await db.execute('''
      CREATE TABLE $_appointmentsTable(
        id TEXT PRIMARY KEY,
        patientId TEXT,
        doctorId TEXT,
        medicalCenterName TEXT,
        doctorName TEXT,
        appointmentDateTime TEXT,
        appointmentCode TEXT,
        status TEXT,
        diagnosis TEXT,
        prescription TEXT
      )
    ''');

    // Crear tabla de Centros Médicos (vinculados a doctores)
    await db.execute('''
      CREATE TABLE $_medicalCentersTable(
        id TEXT PRIMARY KEY,
        name TEXT,
        doctorId TEXT,
        doctorName TEXT,
        phone TEXT,
        address TEXT,
        latitude REAL,
        longitude REAL,
        imageUrl TEXT
      )
    ''');

    // Crear tabla de Horarios de Doctores
    await db.execute('''
      CREATE TABLE $_doctorSchedulesTable(
        id TEXT PRIMARY KEY,
        doctorId TEXT,
        dayOfWeek INTEGER,
        startTime TEXT,
        endTime TEXT
      )
    ''');
  }

  // Métodos para USUARIOS
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      _usersTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      _usersTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Métodos para CITAS
  Future<void> insertAppointment(Appointment appointment) async {
    final db = await database;
    await db.insert(
      _appointmentsTable,
      appointment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _appointmentsTable,
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'appointmentDateTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _appointmentsTable,
      where: 'doctorId = ?',
      whereArgs: [doctorId],
      orderBy: 'appointmentDateTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final db = await database;
    await db.update(
      _appointmentsTable,
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final db = await database;
    await db.delete(
      _appointmentsTable,
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  // Métodos para CENTROS MÉDICOS
  Future<void> insertMedicalCenter(MedicalCenter center) async {
    final db = await database;
    await db.insert(
      _medicalCentersTable,
      center.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MedicalCenter>> getAllMedicalCenters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _medicalCentersTable,
    );
    return List.generate(maps.length, (i) {
      return MedicalCenter.fromMap(maps[i]);
    });
  }

  Future<MedicalCenter?> getMedicalCenterById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _medicalCentersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return MedicalCenter.fromMap(maps.first);
    }
    return null;
  }

  Future<MedicalCenter?> getMedicalCenterByDoctorId(String doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _medicalCentersTable,
      where: 'doctorId = ?',
      whereArgs: [doctorId],
    );
    if (maps.isNotEmpty) {
      return MedicalCenter.fromMap(maps.first);
    }
    return null;
  }

  // Métodos para HORARIOS DE DOCTORES
  Future<void> insertDoctorSchedule(DoctorSchedule schedule) async {
    final db = await database;
    await db.insert(
      _doctorSchedulesTable,
      schedule.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DoctorSchedule>> getDoctorSchedules(String doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _doctorSchedulesTable,
      where: 'doctorId = ?',
      whereArgs: [doctorId],
      orderBy: 'dayOfWeek ASC, startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return DoctorSchedule.fromMap(maps[i]);
    });
  }

  Future<List<DoctorSchedule>> getDoctorSchedulesByDay(
    String doctorId,
    int dayOfWeek,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _doctorSchedulesTable,
      where: 'doctorId = ? AND dayOfWeek = ?',
      whereArgs: [doctorId, dayOfWeek],
      orderBy: 'startTime ASC',
    );
    return List.generate(maps.length, (i) {
      return DoctorSchedule.fromMap(maps[i]);
    });
  }

  Future<void> deleteDoctorSchedule(String scheduleId) async {
    final db = await database;
    await db.delete(
      _doctorSchedulesTable,
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }
}
