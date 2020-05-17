import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_todo/data/todo.dart';
import 'package:equatable/equatable.dart';
import '../repository/hive_repository.dart';
part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  HiveRepository hiveRepo;   // An instance of the class HiveRepo which is used to make calls to Hive
  TodoBloc(this.hiveRepo);
  
  // Returns the TodoInitial state
  @override
  TodoState get initialState => TodoInitial();

  /*
  mapEventToState is a compulsory function for blocs that maps an event to a state- 
  it returns a stream of states (hence marked async* and yield is used)
  It takes an event of the type TodoEvent as an argument and keeps returning states while the bloc is active
  * At the end of processing adding/updating/deleting/toggling status => a call is made to Hive to return the 
  list corresponding to the respective date and the GetTodoState is initialized with the list of todos of that
  day and then returned
  */
  @override
  Stream<TodoState> mapEventToState(
    TodoEvent event,
  ) async* {
    
    if (event is GetTodoEvent) {
      String date = event.date;
    
    //If the list for the particular day is empty, then the TodoInitial state is returned
      if (hiveRepo.getTodo(date) == null)
        yield TodoInitial();
      else {
        List<dynamic> todayList = hiveRepo.getTodo(date);
        yield GetTodoState(todayList);
      }
    
    } else if (event is AddTodoEvent) {
      String date = event.todo.date;
      hiveRepo.addTodo(event.todo);
      List<dynamic> todayList = hiveRepo.getTodo(date);
      yield GetTodoState(todayList);
    
    } else if (event is DeleteTodoEvent) {
      hiveRepo.deleteTodo(event.today, event.index);
      List<dynamic> todayList = hiveRepo.getTodo(event.today);
      yield GetTodoState(todayList);
    
    } else if (event is CompleteTodoEvent) {
      hiveRepo.completeTodo(event.today, event.index, event.value);
      List<dynamic> todayList = hiveRepo.getTodo(event.today);
      yield GetTodoState(todayList);
    
    } else if (event is UpdateTodoEvent) {
      hiveRepo.updateTodo(event.today, event.index, event.todo);
      List<dynamic> todayList = hiveRepo.getTodo(event.today);
      yield GetTodoState(todayList);
    }
  }
}
