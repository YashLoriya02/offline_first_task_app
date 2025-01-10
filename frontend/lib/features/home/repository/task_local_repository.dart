import 'package:frontend/core/services/sp_service.dart';
import 'package:frontend/models/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskLocalRepository {
  final tableName = "tasks";
  final spService = SPService();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    return openDatabase(
      path,
      version: 6,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN isSynced INTEGER NOT NULL');
        }
      },
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tableName(
          mongoId TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          hexColor TEXT NOT NULL,
          userId TEXT NOT NULL,
          id TEXT NOT NULL,
          dueAt TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          isSynced INTEGER NOT NULL
        )
       ''');
      },
    );
  }

  Future<void> insertTasks(List<TaskModel> taskModel) async {
    final db = await database;
    final batch = db.batch();
    for (final task in taskModel) {
      batch.insert(
        tableName,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertTask(TaskModel taskModel) async {
    taskModel.mongoId = "mongoId";
    final db = await database;
    db.insert(
      tableName,
      taskModel.toMap(),
    );
  }

  Future<List<TaskModel>?> getTasks() async {
    final db = await database;
    final result = await db.query(tableName);
    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (final elem in result) {
        tasks.add(TaskModel.fromMap(elem));
      }
      return tasks;
    }
    return null;
  }

  Future<List<TaskModel>> getUnSyncedTasks() async {
    final db = await database;
    final result =
        await db.query(tableName, where: 'isSynced = ?', whereArgs: [0]);
    if (result.isNotEmpty) {
      List<TaskModel> tasks = [];
      for (final elem in result) {
        tasks.add(TaskModel.fromMap(elem));
      }
      return tasks;
    }
    return [];
  }

  Future<void> updateSync(String id, int newValue) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': newValue},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
