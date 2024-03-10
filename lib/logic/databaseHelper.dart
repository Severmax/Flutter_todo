import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

  class DatabaseHelper{

    static final DatabaseHelper _self = DatabaseHelper.internal();
    factory DatabaseHelper() => _self;
    DatabaseHelper.internal(); //инициализирую статический екземп класса

    final String tableTasks = 'tasks';
    final String columnId = 'id';
    final String columnDescription = 'description';
    final String columnDate = 'date';
    final String columnTime = 'time';
    final String columnImagePath = 'imagePath';

    static Database? _db;

    Future<Database?> get db async {
      if (_db != null) {
        return _db;
      }
      _db = await initDb();
      return _db;
    }

    Future<Database> initDb() async {
      String dbPath = await getDatabasesPath();
      String path = join(dbPath, 'tasks.db');

      var db = await openDatabase(path, version: 1, onCreate: _onCreate);
      return db;
    }

    void _onCreate(Database db, int newVersion) async {
      await db.execute('''
      CREATE TABLE $tableTasks (
        $columnId INTEGER PRIMARY KEY,
        $columnDescription TEXT,
        $columnDate TEXT,
        $columnTime TEXT,
        $columnImagePath TEXT
      )
      ''');
    }

    Future<int> addTask(Map<String, dynamic> task) async {
      var dbClient = await db;
      return await dbClient!.insert(tableTasks, task); //вернет -1 при исключении
    }

    Future<int> deleteTask(int id) async {
      var dbClient = await db;
      return await dbClient!.delete( // вернет количиство удаленных строк
        tableTasks,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    }

    Future<int> updateTask(Map<String, dynamic> task) async {
      var dbClient = await db;
      return await dbClient!.update(
        tableTasks,
        task,
        where: '$columnId = ?',
        whereArgs: [task[columnId]],
      );
    }

    Future<List<Map<String, dynamic>>> getTasksForDay(DateTime date) async {
      var dbClient = await db;
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      return await dbClient!.query(
        tableTasks,
        where: '$columnDate = ?',
        whereArgs: [formattedDate],
      );
    }

    Future<List<DateTime>> getDaysWithTasks() async {
      var dbClient = await db;
      List<Map<String, dynamic>> result = await dbClient!.query(
        tableTasks,
        columns: ['$columnDate'],
        groupBy: '$columnDate',
      );
      List<DateTime> daysWithTasks = [];
      for (var item in result) {
        String dateString = item[columnDate];
        DateTime date = DateTime.parse(dateString);
        daysWithTasks.add(date);
      }
      return daysWithTasks;
    }

    Future<Map<String, dynamic>?> getLastInsertedTask() async {
      var dbClient = await db;
      List<Map<String, dynamic>> result = await dbClient!.query(
        tableTasks,
        orderBy: '$columnId DESC',
        limit: 1, // возврат только одной записи
      );
      if (result.isNotEmpty) {
        return result.first;
      } else {
        return null;
      }
    }
  }