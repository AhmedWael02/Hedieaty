import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Users (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phoneNumber TEXT,
            password TEXT,
            themePreference TEXT,
            notificationsEnabled INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE Events (
            id TEXT PRIMARY KEY,
            name TEXT,
            date TEXT,
            location TEXT,
            description TEXT,
            category TEXT,
            status TEXT,
            userId TEXT,
            isPublished INTEGER,
            FOREIGN KEY (userId) REFERENCES Users (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE Gifts (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            category TEXT,
            price REAL,
            status TEXT,
            pledgedByUserId TEXT,
            eventId TEXT,
            FOREIGN KEY (eventId) REFERENCES Events (id)
            FOREIGN KEY (pledgedByUserId) REFERENCES Users (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE Friends (
            userId TEXT,
            friendId TEXT,
            PRIMARY KEY (userId, friendId),
            FOREIGN KEY (userId) REFERENCES Users (id)
          )
        ''');
      },
    );
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db');
    await databaseFactory.deleteDatabase(path);
  }


  // Insert User
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('Users', user);
  }

// Get All Users
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('Users');
  }

  Future<int> updateUser(Map<String, dynamic> user, String userId) async {
    final db = await database;
    return await db.update(
      'Users',
      user,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }


// Insert Event
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('Events', event);
  }

// Get Events by User ID
  Future<List<Map<String, dynamic>>> getEventsByUserId(String userId) async {
    final db = await database;
    return await db.query('Events', where: 'userId = ?', whereArgs: [userId]);
  }

// Insert Gift
  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('Gifts', gift);
  }

// Get Gifts by Event ID
  Future<List<Map<String, dynamic>>> getGiftsByEventId(String eventId) async {
    final db = await database;
    return await db.query('Gifts', where: 'eventId = ?', whereArgs: [eventId]);
  }

// Insert Friend
  Future<int> insertFriend(String userId, String friendId) async {
    final db = await database;
    return await db.insert('Friends', {'userId': userId, 'friendId': friendId});
  }

// Get Friends by User ID
  Future<List<Map<String, dynamic>>> getFriendsByUserId(String userId) async {
    final db = await database;
    return await db.query('Friends', where: 'userId = ?', whereArgs: [userId]);
  }




}
