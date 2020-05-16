import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'todo.g.dart';

@HiveType()
class Todo {
  @HiveField(0)
  String date;  //used to store the date associated with the todo item
  @HiveField(1) 
  String description;   // a description of the todo item
  @HiveField(2)
  bool isCompleted;
  Todo(@required this.description, @required this.date,
      {this.isCompleted = false});
}
