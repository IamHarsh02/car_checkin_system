import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  final String tableName = 'cars';

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'car_log.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        carNumber TEXT PRIMARY KEY,
        checkInTime TEXT NOT NULL,
        checkOutTime TEXT
      )
    ''');
  }

  Future<int> insertCar(Map<String, dynamic> car) async {
    final db = await database;
    return await db.insert(tableName, car, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllCars() async {
    final db = await database;
    return await db.query(tableName);
  }

  Future<int> updateCar(Map<String, dynamic> car) async {
    final db = await database;
    return await db.update(
      tableName,
      car,
      where: 'carNumber = ?',
      whereArgs: [car['carNumber']],
    );
  }

  Future<int> deleteCar(String carNumber) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'carNumber = ?',
      whereArgs: [carNumber],
    );
  }
}