import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todo/bloc/todo_bloc.dart';
import 'package:bloc_todo/data/todo.dart';
import 'package:bloc_todo/repository/hive_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockHiveRepo extends Mock implements HiveRepository {}
// Written tests to test all 5 events of the TodoBloc and check for matching streams


void main() {
  //Mockito is used to create a mock(fake) hive repository to reduce the dependencies and latency in testing
  MockHiveRepo mockHiveRepo;
  //this function is run before every test, and it initializes an instance of the mock repository
  setUp(() {
    mockHiveRepo = MockHiveRepo();
  });
  //Two todo instances are declared and initialized for use
  final Todo testTodo = Todo('todo check', '2020-06-19');
  final Todo trueTodo = Todo('todo check', '2020-06-19', isCompleted: true);
  final Todo updateTodo = Todo('todo check before update', '2020-06-19');
  final String date = '2020-06-19';
  final int index = 0;
  /* getting todos - When any date is entered, the function getTodo will return testTodo
    and when the GetTodoEvent is added to the block with the date, its todos are gotten
    and expect is used to match streams (the stream of states dispatched by the bloc and
    the stream of states we are expecting)
  */
  blocTest('Getting a todo ',
      build: () async {
        when(mockHiveRepo.getTodo(any)).thenAnswer((_) => <dynamic>[testTodo]);
        return TodoBloc(mockHiveRepo);
      },
      act: (bloc) => bloc.add(GetTodoEvent('2020-06-19')),
      expect: [
        GetTodoState(<dynamic>[testTodo])
      ]);

/* Adding a todo
when addTodo call is made to the mock repo, it calls getTodo which outputs 
a list containing testTodo, which is then compared with the stream of states (GetTodoState([testTodo]))
The number of method calls are verified too
*/
  blocTest('Adding a todo',
      build: () async {
        when(mockHiveRepo.getTodo(date))
            .thenAnswer((realInvocation) => <dynamic>[testTodo]);
        when(mockHiveRepo.addTodo(testTodo))
            .thenAnswer((realInvocation) => mockHiveRepo.getTodo(date));
        return TodoBloc(mockHiveRepo);
      },
      act: (bloc) => bloc.add(AddTodoEvent(testTodo)),
      verify: (_) async {
        verify(mockHiveRepo.addTodo(any)).called(1);
        verify(mockHiveRepo.getTodo(any)).called(2);
      },
      expect: [
        GetTodoState(<dynamic>[testTodo])
      ]);

// Updating a todo

  blocTest('Updating a todo',
      build: () async {
        when(mockHiveRepo.getTodo('2020-06-19'))
            .thenAnswer((realInvocation) => <dynamic>[updateTodo]);
        when(mockHiveRepo.updateTodo(date, index, updateTodo))
            .thenAnswer((realInvocation) => mockHiveRepo.getTodo(date));
        return TodoBloc(mockHiveRepo);
      },
      act: (bloc) => bloc.add(UpdateTodoEvent(date, index, updateTodo)),
      verify: (_) async {
        verify(mockHiveRepo.updateTodo(any, any, any)).called(1);
        verify(mockHiveRepo.getTodo(any)).called(2);
      },
      expect: [
        GetTodoState(<dynamic>[updateTodo])
      ]);

  blocTest('Deleting a todo',
      build: () async {
        when(mockHiveRepo.deleteTodo(date, index))
            .thenAnswer((realInvocation) => mockHiveRepo.getTodo(date));
        when(mockHiveRepo.getTodo(date))
            .thenAnswer((realInvocation) => <dynamic>[]);
        return TodoBloc(mockHiveRepo);
      },
      act: (bloc) => bloc.add(DeleteTodoEvent(date, index)),
      expect: [GetTodoState(<dynamic>[])]);

  blocTest('Completing a todo',
      build: () async {
        when(mockHiveRepo.completeTodo(date, index, false))
            .thenAnswer((realInvocation) => null);
        when(mockHiveRepo.getTodo(date))
            .thenAnswer((realInvocation) => <dynamic>[trueTodo]);
        return TodoBloc(mockHiveRepo);
      },
      act: (bloc) => bloc.add(CompleteTodoEvent(date, index, false)),
      expect: [
        GetTodoState(<dynamic>[trueTodo])
      ]);
}
