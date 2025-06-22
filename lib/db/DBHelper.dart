import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import '../model/NoteModel.dart';
import '../model/TaskModel.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper.internal();

  DBHelper.internal();

  static DBHelper get instance => _instance;

  Database? _database;
  String tasksTable = "Tasks";
  String notesTable = "Notes";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    final dbPath = await getDatabasesPath();
    const dbName = 'TODO.db';
    final dbFile = path.join(dbPath, dbName);
    return await openDatabase(
      dbFile,
      version: 1,
      onCreate: (db, version) => _createDB(db, version),
    );
  }

  _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tasksTable (
        id INTEGER PRIMARY KEY,
        title TEXT,
        type TEXT,
        insertedDate TEXT,
        time TEXT,
        remainderTime INTEGER,
        status INTEGER DEFAULT 0  
      )''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $notesTable (
        id INTEGER PRIMARY KEY,
        msg TEXT,
        dateTime TEXT,
        noteImageIndex INTEGER
      )''');
  }

  //tasks

  //get all task
  Future<List<Task>> getAllTasks() async {
    final db = await DBHelper.instance.database;
    final tasks = await db.query(tasksTable);
    return tasks
        .map(
          (e) => Task.fromMap(e),
    )
        .toList();
  }

  //get tasks by category
  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await DBHelper.instance.database;
    final tasks = await db.query(tasksTable);
    return tasks
        .map(
          (e) => Task.fromMap(e),
    ).where(
      (element) {
        if(element.type == category){
          return true;
        }
        return false;
      },
    )
        .toList();
  }

  //get task by different/distinct date
  Future<List<Map<String, dynamic>>> getDistinctDate() async {
    String query = "Select DISTINCT insertedDate from $tasksTable order by insertedDate ASC";
    final db = await DBHelper.instance.database;
    List<Map<String, dynamic>> dates = await db.rawQuery(query);
    return dates;
  }

  //get one task
  Future<Task> getTask(int id) async {
    final db = await DBHelper.instance.database;
    final task = await db.query(tasksTable,where: 'id = ?',whereArgs: [id]);
    return Task.fromMap(task[0]);
  }

  //create new task
  Future<int> createTask(Task task) async {
    final db = await DBHelper.instance.database;
    final isInserted = await db.insert(tasksTable, task.toMap());
    return isInserted;
  }

  //update status of task
  Future<int> updateTask(int id, int status) async {
    final db = await DBHelper.instance.database;
    final isUpdated = await db.update(tasksTable, {"status":status},where: "id = ?",whereArgs: [id]);
    return isUpdated;
  }

  //update status of task
  Future<int> updateTaskDetails(Task task) async {
    final db = await DBHelper.instance.database;
    final isUpdated = await db.update(tasksTable, task.toMap(),where: "id = ?",whereArgs: [task.id]);
    return isUpdated;
  }

  //delete task
  Future<int> deleteTask(int id) async {
    final db = await DBHelper.instance.database;
    final isDeleted = await db.delete(tasksTable,where: 'id = ?',whereArgs: [id]);
    return isDeleted;
  }


  //notes

  //get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await DBHelper.instance.database;
    final notes = await db.query(notesTable);
    return notes
        .map(
          (e) => Note.fromMap(e),
    )
        .toList();
  }

  //create new note
  Future<int> createNote(Note note) async {
    final db = await DBHelper.instance.database;
    final isInserted = await db.insert(notesTable, note.toMap());
    return isInserted;
  }

  //update msg of note
  Future<int> updateNote(int id, String msg) async {
    final db = await DBHelper.instance.database;
    final isUpdated = await db.update(notesTable, {"msg":msg},where: "id = ?",whereArgs: [id]);
    return isUpdated;
  }

  //delete note
  Future<int> deleteNote(int id) async {
    final db = await DBHelper.instance.database;
    final isDeleted = await db.delete(notesTable,where: 'id = ?',whereArgs: [id]);
    return isDeleted;
  }
}