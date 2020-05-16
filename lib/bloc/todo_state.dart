part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  const TodoState();
}
// The TodoInitial state is used to sepcify an initial (starting) state for the app
class TodoInitial extends TodoState {
  @override
  List<Object> get props => [];
}

// GetTodoState is used to specify a state which receives and stores the list of todos associated with a particular day
class GetTodoState extends TodoState {
  final List<dynamic> todayList;
  GetTodoState(this.todayList);
  @override
  List<Object> get props => [todayList];
}
