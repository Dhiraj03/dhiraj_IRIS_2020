part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
}

// Getting(retrieving todos associated with a date)
class GetTodoEvent extends TodoEvent {
  final String date;
  const GetTodoEvent(this.date);
  @override
  List<Object> get props => [date];
}

// Adding a todo to a particular date
class AddTodoEvent extends TodoEvent {
  final Todo todo;
  const AddTodoEvent(this.todo);
  @override
  List<Object> get props => [todo];
}

// Updating the description of a todo item
class UpdateTodoEvent extends TodoEvent {
  final String today;
  final int index;
  final Todo todo;
  const UpdateTodoEvent(this.today, this.index, this.todo);
  @override
  List<Object> get props => [today, index];
}

// Deleting an instance of a todo
class DeleteTodoEvent extends TodoEvent {
  final String today;
  final int index;
  const DeleteTodoEvent(this.today, this.index);
  @override
  List<Object> get props => [today, index];
}

// Toggling the status of completion of a todo
class CompleteTodoEvent extends TodoEvent {
  final String today;
  final int index;
  final bool value;
  const CompleteTodoEvent(this.today, this.index, this.value);
  @override
  List<Object> get props => [today, index];
}
