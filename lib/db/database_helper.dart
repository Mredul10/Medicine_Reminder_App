import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';
import '../models/reminder.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init('medicine_reminder.db');
    return _db!;
  }

  Future<Database> _init(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // 1. CREATE medicines table
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT,
        notes TEXT
      )
    ''');

    // 2. CREATE reminders table
    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_id INTEGER,
        time TEXT,
        FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE
      )
    ''');
  }

  // 3. INSERT medicine + insert reminders (4. INSERT reminders)
  Future<int> insertMedicine(Medicine med) async {
    final db = await database;
    final medId = await db.insert('medicines', med.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    for (var t in med.scheduleTimes) {
      await db.insert('reminders', {'medicine_id': medId, 'time': t});
    }
    return medId;
  }

  // 5. SELECT all medicines with reminders
  Future<List<Medicine>> getAllMedicines() async {
    final db = await database;
    final medMaps = await db.query('medicines', orderBy: 'id DESC');
    List<Medicine> list = [];
    for (var m in medMaps) {
      final reminders = await db.query('reminders', where: 'medicine_id = ?', whereArgs: [m['id']]);
      final times = reminders.map((r) => r['time'] as String).toList();
      list.add(Medicine.fromMap(m, times));
    }
    return list;
  }

  // 6. SELECT medicine by id with reminders
  Future<Medicine?> getMedicineById(int id) async {
    final db = await database;
    final res = await db.query('medicines', where: 'id = ?', whereArgs: [id]);
    if (res.isEmpty) return null;
    final rem = await db.query('reminders', where: 'medicine_id = ?', whereArgs: [id]);
    final times = rem.map((r) => r['time'] as String).toList();
    return Medicine.fromMap(res.first, times);
  }

  // 7. UPDATE medicine (only medicine fields)
  Future<int> updateMedicine(Medicine med) async {
    final db = await database;
    return await db.update('medicines', med.toMap(), where: 'id = ?', whereArgs: [med.id]);
  }

  // 8. UPDATE reminder time
  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  // 9. DELETE a medicine (and associated reminders)
  Future<int> deleteMedicine(int id) async {
    final db = await database;
    // Explicitly delete reminders first (10. DELETE all reminders for a medicine)
    await db.delete('reminders', where: 'medicine_id = ?', whereArgs: [id]);
    return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  // 10. DELETE all reminders for a medicine
  Future<int> deleteRemindersForMedicine(int medId) async {
    final db = await database;
    return await db.delete('reminders', where: 'medicine_id = ?', whereArgs: [medId]);
  }

  // Helpers
  Future<List<Reminder>> getRemindersForMedicine(int medId) async {
    final db = await database;
    final maps = await db.query('reminders', where: 'medicine_id = ?', whereArgs: [medId]);
    return maps.map((m) => Reminder.fromMap(m)).toList();
  }

  Future<int> insertReminder(int medId, String time) async {
    final db = await database;
    return await db.insert('reminders', {'medicine_id': medId, 'time': time});
  }
}
