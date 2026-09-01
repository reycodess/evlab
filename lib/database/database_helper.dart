// lib/database/database_helper.dart

import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
  DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  /// Returns the database instance.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  /// Initializes the EV-LAB SQLite database.
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'evlab.db',
    );

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Creates the experiments table.
  Future<void> _createDatabase(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE experiments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        enzyme_name TEXT NOT NULL,

        temperature REAL NOT NULL,

        ph REAL NOT NULL,

        substrate REAL NOT NULL,

        substrate_unit TEXT NOT NULL,

        inhibitor_type TEXT NOT NULL,

        inhibitor_ratio REAL NOT NULL,

        activity REAL NOT NULL,

        created_at TEXT NOT NULL
      )
    ''');
    await _createLearnerProgressTable(db);
  }

  Future<void> _createLearnerProgressTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS learner_progress (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        xp INTEGER NOT NULL DEFAULT 0,
        completed_lessons INTEGER NOT NULL DEFAULT 0,
        completed_quizzes INTEGER NOT NULL DEFAULT 0,
        quiz_correct_answers INTEGER NOT NULL DEFAULT 0,
        completed_experiments INTEGER NOT NULL DEFAULT 0,
        completed_three_rs INTEGER NOT NULL DEFAULT 0,
        lesson_numbers TEXT NOT NULL DEFAULT '[]',
        badges TEXT NOT NULL DEFAULT '[]',
        updated_at TEXT NOT NULL
      )
    ''');
  }

  /// Handles database upgrades.
  ///
  /// Version 2 keeps the existing experiment structure but
  /// allows future database changes to be added safely.
  Future<void> _upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      // Database version 2.
      //
      // No structural migration is currently required here
      // because fresh installations already use the corrected
      // schema.
    }
    if (oldVersion < 3) {
      await _createLearnerProgressTable(db);
    }
  }

  Future<Map<String, dynamic>> getLearnerProgress() async {
    final db = await database;
    final rows = await db.query('learner_progress', where: 'id = 1');
    if (rows.isNotEmpty) return rows.first;
    final empty = <String, dynamic>{
      'id': 1, 'xp': 0, 'completed_lessons': 0, 'completed_quizzes': 0,
      'quiz_correct_answers': 0, 'completed_experiments': 0,
      'completed_three_rs': 0, 'lesson_numbers': jsonEncode(<int>[]),
      'badges': jsonEncode(<String>[]),
      'updated_at': DateTime.now().toIso8601String(),
    };
    await db.insert('learner_progress', empty);
    return empty;
  }

  Future<void> saveLearnerProgress(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('learner_progress', {...data, 'id': 1,
      'updated_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Inserts one experiment into the database.
  Future<int> insertExperiment(
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    final experiment = {
      'enzyme_name': data['enzyme_name'] ?? data['enzyme'],
      'temperature': data['temperature'],
      'ph': data['ph'],
      'substrate': data['substrate'],
      'substrate_unit': data['substrate_unit'] ?? 'mM',
      'inhibitor_type':
      data['inhibitor_type'] ?? 'none',
      'inhibitor_ratio':
      data['inhibitor_ratio'] ?? 0.0,
      'activity': data['activity'],
      'created_at':
      data['created_at'] ??
          DateTime.now().toIso8601String(),
    };

    return await db.insert(
      'experiments',
      experiment,
    );
  }

  /// Returns all experiments.
  Future<List<Map<String, dynamic>>> getExperiments() async {
    final db = await database;

    return await db.query(
      'experiments',
      orderBy: 'created_at DESC',
    );
  }

  /// Returns experiments for a specific enzyme.
  Future<List<Map<String, dynamic>>> getExperimentsByEnzyme(
      String enzymeName,
      ) async {
    final db = await database;

    return await db.query(
      'experiments',
      where: 'enzyme_name = ?',
      whereArgs: [enzymeName],
      orderBy: 'created_at DESC',
    );
  }

  /// Deletes one experiment.
  Future<int> deleteExperiment(int id) async {
    final db = await database;

    return await db.delete(
      'experiments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all experiments.
  Future<void> clearExperiments() async {
    final db = await database;

    await db.delete('experiments');
  }

  /// Closes the database.
  Future<void> closeDatabase() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}
