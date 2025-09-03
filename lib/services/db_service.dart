import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/letter.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'suratdesa.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE letters(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            noSurat TEXT,
            dariAtauKepada TEXT,
            perihal TEXT,
            tanggal TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insertLetter(Letter letter) async {
    final db = await database;
    return await db.insert('letters', letter.toMap());
  }

  static Future<List<Letter>> getLetters() async {
    final db = await database;
    final res = await db.query('letters', orderBy: 'id DESC');
    return res.map((e) => Letter.fromMap(e)).toList();
  }

  static Future<int> updateLetter(Letter letter) async {
    final db = await database;
    return await db.update('letters', letter.toMap(),
        where: 'id = ?', whereArgs: [letter.id]);
  }

  static Future<int> deleteLetter(int id) async {
    final db = await database;
    return await db.delete('letters', where: 'id = ?', whereArgs: [id]);
  }
}
