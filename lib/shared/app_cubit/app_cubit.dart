import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/completed_tasks_screen.dart';
import 'package:todo_app/modules/tasks/tasks_screen.dart';

import 'app_states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  /// Create static instance of [HomeCubit]
  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  late Database database;

  /// [BottomNavigationBar] screens
  List<Widget> screens = [
    TasksScreen(),
    const CompletedTasksScreen(),
    const ArchivedTasksScreen()
  ];

  /// Tasks List
  List<Map> newTasks = [];
  List<Map> completedTasks = [];
  List<Map> archiveTasks = [];
  bool isBottomSheetOpened = false;
  IconData fabIcon = Icons.edit;
  Color taskColor = Colors.blueAccent;

  /// Change [BottomNavigationBar] current index
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  /// Database creation
  void createDatabase() {
    openDatabase("todo.db", version: 1, onCreate: (database, version) {
      print('Database Created');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) => {print('Tasks Table Created')})
          .catchError((error) {
        print('Error When Creating Tasks Table => ${error.toString()}');
      });
    }, onOpen: (database) {
      print('Database Opened');

      /// Get new tasks after insert to refresh list
      getTasks(database);
    }).then((value) => {
          database = value,
          emit(AppCreateDatabaseState()),
        });
  }

  /// Insert task record in database
  void insertTask(
      {required String title,
      required String time,
      required String date}) async {
    return await database.transaction((txn) {
      return txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES ("$title", "$date", "$time", "new")')
          .then((value) {
        print('${value.toString()} Inserted Successfully :)');
        emit(AppInsertDatabaseState());

        /// Get new tasks after insert to refresh list
        getTasks(database);
      }).catchError((error) {
        print(error.toString());
      });
    });
  }

  /// Get tasks records from database
  void getTasks(database) {
    newTasks.clear();
    completedTasks.clear();
    archiveTasks.clear();
    database.rawQuery('SELECT * FROM tasks').then((value) => {
          value.forEach((element) {
            if (element['status'] == 'new') {
              newTasks.add(element);
            } else if (element['status'] == 'done') {
              completedTasks.add(element);
            } else {
              archiveTasks.add(element);
            }
          }),
          emit(AppGetDatabaseState()),
        });
  }

  /// Update status of task
  void updateTaskStatus({required String status, required int taskId}) {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', taskId],
    ).then((value) => {
          /// Get tasks after update to refresh list
          getTasks(database),
          emit(AppUpdateDatabaseState())
        });
  }

  /// Delete task
  void deleteTask({required int taskId}) {
    database
        .rawDelete('DELETE FROM tasks WHERE id = ?', [taskId]).then((value) => {
              /// Get tasks after delete to refresh list
              getTasks(database),
              emit(AppDeleteDatabaseState()),
            });
  }

  /// Change [BottomSheet] visibility and [FloatingActionButton] icon
  void changeBottomSheetState({required bool isOpen, required IconData icon}) {
    isBottomSheetOpened = isOpen;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
