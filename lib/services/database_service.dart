import 'package:find_my_spot/models/spot_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static const _dbVersion = 2;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'spots.db');

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
    CREATE TABLE spots (
    id INTEGER  PRIMARY KEY AUTOINCREMENT,
    name TEXT, 
    description TEXT,
    latitude REAL,
    longitude REAL,
    imagePaths TEXT,
    createdAt TEXT
    )
    ''');
  }

  Future<int> addSpot(Spot spot) async {
    final db = await instance.database;
    return await db.insert('spots', spot.toMap());
  }

  Future<List<Spot>> getAllSpots() async {
    final db = await instance.database;
    final result = await db.query('spots');
    return result.map((map) => Spot.fromMap(map)).toList();
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE spots ADD COLUMN createdAt TEXT');
    }
  }

  Future closeDB() async {
    final db = await instance.database;
    db.close();
  }
}
