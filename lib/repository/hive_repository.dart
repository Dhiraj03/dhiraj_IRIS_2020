import 'dart:core';
import 'package:bloc_todo/data/todo.dart';
import 'package:hive/hive.dart';

abstract class Repository {   
  const Repository();
}

class HiveRepository {
  
  // getTodo is a function that receives the date (String) and returns a list of todos
  List<dynamic> getTodo(String date) {
    final Box box = Hive.box<dynamic>('todo1');
    List<dynamic> todayList = box.get(date) as List<dynamic>;
    return todayList;
  }

  // addTodo takes an instance of the Todo class as argument and store it in the key-entry associated with the date
  void addTodo(Todo todo) {
    final Box box = Hive.box<dynamic>('todo1');
    
    /* if the list is not null (a todo item already exists, then it is retrieved and then updated and stored) 
    and if it doesn't exist,a list is created, the todo item is added and then stored*/
    if (box.get(todo.date) == null) {
      List<Todo> todayList = [];
      todayList.add(todo);
      box.put(todo.date, todayList);
    } else {
      var todayList = box.get(todo.date) as List<dynamic>;
      todayList.add(todo);
      box.put(todo.date, todayList);
    }
  }

  // updateTodo takes the date, index of the todo item and the todo instance and retrieves the list, updates the item and stores it back
  void updateTodo(String date, int index, Todo todo) {
    final Box box = Hive.box<dynamic>('todo1');
    List<dynamic> todayList = box.get(date);
    todayList[index] = todo;
    box.put(date, todayList);
  }

  // deleteTodo takes the date and the index of the todo item, retrieves the list, deletes the particular instance and stores it back
  void deleteTodo(String date, int index) {
    final Box box = Hive.box<dynamic>('todo1');
    List<dynamic> todayList = box.get(date);
    todayList.removeAt(index);
    box.put(date, todayList);
  }

  // completeTodo takes the date, index and status of completion, retrieves the list, deletes the particular instances and stores it back
  void completeTodo(String date, int index, bool value) {
    final Box box = Hive.box<dynamic>('todo1');
    List<dynamic> todayList = box.get(date);
    todayList[index].isCompleted = value;
    box.put(date, todayList);
  }
}
