import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        dueDate TEXT,        
        createdAt TEXT
      )
    ''');
  }

  Future<int> create(Todo todo) async {
    final db = await instance.database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> readAllTodos() async {
    final db = await instance.database;
    final result = await db.query('todos');
    return result.map((map) => Todo.fromMap(map)).toList();
  }

  Future<int> update(Todo todo) async {
    final db = await instance.database;
    return await db
        .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
