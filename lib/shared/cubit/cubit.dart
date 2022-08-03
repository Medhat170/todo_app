import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udemy_flutter/modules/todo_app/archived_tasks/archived_tasks_screen.dart';
import 'package:udemy_flutter/modules/todo_app/done_tasks/done_tasks_screen.dart';
import 'package:udemy_flutter/modules/todo_app/new_tasks/new_tasks_screen.dart';
import 'package:udemy_flutter/shared/cubit/states.dart';
class AppCubit extends Cubit<AppStates>
{
 AppCubit(): super(AppInitialState());

 static AppCubit get(context) => BlocProvider.of(context);
 int currentIndex = 0;
 late Database database;

 List<Map> newTasks = [];
 List<Map> doneTasks = [];
 List<Map> archivedTasks = [];

 List<Widget> screens =
 [
  NewTasksScreen(),
  const DoneTasksScreen(),
  const ArchivedTasksScreen()
 ];

 List<String> title =
 [
  'New Tasks',
  'Done Tasks',
  'Archived tasks'
 ];

 void changeIndex(int index)
 {
  currentIndex = index;
  emit(AppChangeBottomNavBarState());
 }

 // to make a clean code, you should make everything in methods
 void createDatabase()
 {
  openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version)
      {
       print('database created');
       database.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)').then((value)
       {
        print('table created');
       }).catchError((error){
        print('Error when creating table: ${error.toString()}');
       });

      },
      onOpen: (database)
      {
       // هنا انا اخدت قيمة ال list
       // في ال value يعني ال value دلوقي نوعها list<Map
       // so I need list to store the VALUE(its type is list<Map>)
       getDataFromDatabase(database);
       ('database opened');
      },
  ).then((value)
  {
   database = value;
   emit(AppCreateDatabaseState());
  });
 }
 Future insertToDatabase({
  required String title,
  required String time,
  required String date,
 }) async
 {
  await database.transaction((txn)
  {
   return txn.rawInsert('INSERT INTO tasks (title, date, time, status) VALUES("$title","$date","$time","new")'
   ).then((values) {
    print('$values inserted successfully');
    emit(AppInsertDatabaseState());
    getDataFromDatabase(database);

   }).catchError((error) {
    print('Error when inserting New Record ${error.toString()}');
   });
  });
 }

 void getDataFromDatabase(database)
 {
  newTasks = [];
  doneTasks = [];
  archivedTasks = [];

  emit(AppGetDatabaseLoadingState());
  database.rawQuery('SELECT * FROM tasks').then((value)
  {
   value.forEach((element) {
    if(element['status'] == 'new') {
      newTasks.add(element);
    }
    else if(element['status'] == 'done'){
     doneTasks.add(element);
    }
    else {
      archivedTasks.add(element);
    }
   });

   emit(AppGetDatabaseState());
  });
 }

 void updateData({
 required String status,
 required int id,
}) async
 {
  database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id= ?',
      [status, id],
  ).then((value)
  {
   getDataFromDatabase(database);
   emit(AppUpdateDatabaseState());
  }
  );
 }
 void deleteData({
  required int id,
 }) async
 {
  database.rawUpdate(
   'DELETE FROM tasks WHERE ID = ?', [id],
  ).then((value)
  {
   getDataFromDatabase(database);
   emit(AppDeleteDatabaseState());
  }
  );
 }
 bool isBottomSheetShown = false;
 IconData? fabIcon = Icons.edit;

 void changeBottomSheetState(
 {
 required bool isShow,
 required IconData icon,
 })
 {
  isBottomSheetShown = isShow;
  fabIcon = icon;
  emit(AppChangeBottomSheetState());
 }

}