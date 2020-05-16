import 'dart:io';
import 'package:bloc_todo/data/todo.dart';
import 'package:bloc_todo/repository/hive_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:table_calendar/table_calendar.dart';
import 'bloc/todo_bloc.dart';

// The main() function is defined below, marked async because it includes an asynchronous call
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory appDocumentDir =                     // Used to get the location of the directory where the Hive data will be stored
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);   // Initializes Hive
  Hive.registerAdapter(TodoAdapter(), 0);   // Registers the type adapter needed for the project - Todo Class
  final Box box = await Hive.openBox<dynamic>('todo1');  // Opens the box - can be used anywhere else in the project using .box()
  runApp(MyApp());    // runs the MyApp class' build function
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _calendarController;    // calendar controller is a mandatory property for TableCalendar 
  static HiveRepository hiveRepo = HiveRepository();   //Initializes an instance of the HiveRepository class to be used to initialize an instance of the TodoBloc
  final TodoBloc _todoBloc = TodoBloc(hiveRepo);       // Initializes an instance of the TodoBloc to be used in the BlocProvider widget
  final TextEditingController _descController = TextEditingController(); // TextEditingController used for the Add todo option
  final TextEditingController _updateController = TextEditingController();  // TextEditingController used for the Update todo option
  String today;   // Used to store the selectedDay on the TableCalendar widget
  DateTime chosenDate;   // Stores the day picked on the date picker
  String formattedDate;   // String version ('yyyy-mm-dd' format) of the date picked
  List<dynamic> todayList;   // Stores the list of todos for the day selected on the calendar, to be used in the ListView.builder widget
  
  //  initState() is used to initialize the calendar controller
  @override  
  void initState() {
    super.initState();
    _calendarController = CalendarController();
   
  }

// Used to dispose the instance of the calendar controller
  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(92, 6, 50, 1.0),
        title: const Text('Todo App'),
      ),
      // BlocBuilder is used to receive changes in state and rebuild if the state has changed
      body: BlocBuilder<TodoBloc, TodoState>(
          bloc: _todoBloc,   
          builder: (BuildContext context, TodoState state) {
            print('Called');
            if (state is TodoInitial) {   
              /* If the state is TodoInitial, the ListView.builder widget will not be present and 
              only the calendar and add todo option will be present 
              */
              return Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                    TableCalendar(    //used to display the calendar on the home page
                        calendarController: _calendarController,
                        calendarStyle: const CalendarStyle(
                          selectedColor: Color.fromRGBO(92, 6, 50, 1.0),
                          todayColor: Color.fromRGBO(92, 6, 50, 0.5)
                        ),
                        onDaySelected: (DateTime date, List<dynamic> events) {    // Used to specify what happens when a date is selected
                          setState(() {
                            today = DateFormat('yyyy-MM-dd').format(date);  
                          });
                          _todoBloc.add(GetTodoEvent(today));   //When the selectedDate is changed, the event GetTodoEvent is sent to the bloc to get the Todos for the selectedDate
                        }),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                              color: const Color.fromRGBO(92, 6, 50, 1.0),
                              child: Text('Add a todo',
                                           style: TextStyle(color: Colors.white)),
                              onPressed: () => 
                              showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(    //Stateful Builder is used to rebuild the AlertDialog to show the pickedDate in the dialog box whenever it is changed
                                      builder: (BuildContext context, Function rebuild) => 
                                      AlertDialog(
                                          title: const Text(
                                            'Add a new Todo',
                                            style: TextStyle( color: Color.fromRGBO(92, 6, 50, 1.0)),
                                                          ),
                                          content: SingleChildScrollView(  //Used so that the column does not unnecessarily extend the height of the dialog box
                                            child: Column(
                                            children: <Widget>[
                                              TextFormField(   //Used to input the description of the todo
                                                style: const TextStyle(color: Color.fromRGBO(92, 6, 50, 1.0),
                                                                       fontWeight:FontWeight.bold),
                                                decoration: const InputDecoration(
                                                  labelText:'Enter the description here',
                                                  labelStyle:  TextStyle(color: Color.fromRGBO(92, 6, 50, 1.0)),
                                                  fillColor:  Color.fromRGBO(92, 6, 50, 1.0),
                                                  icon:  Icon(
                                                    Icons.description,
                                                    color: Color.fromRGBO(92, 6, 50, 1.0),
                                                  ),
                                                  focusColor:  Color.fromRGBO( 92, 6, 50, 1.0),
                                                  focusedBorder:  UnderlineInputBorder(
                                                        borderSide: BorderSide(color: Color.fromRGBO(92, 6, 50, 1.0)),
                                                            ),
                                                  ),
                                                controller: _descController,
                                              ),
                                              
                                              const SizedBox(height: 20),
                                              
                                              Row(
                                                children: <Widget>[
                                                  RaisedButton(
                                                      child: Text('Choose Date',
                                                                   style: TextStyle(color:Colors.white),
                                                                 ),
                                                      color: const Color.fromRGBO( 92, 6, 50, 1.0),
                                                      onPressed: () =>
                                                          showDatePicker(    //used to display the datePicker
                                                                  context : context,
                                                                  initialDate : DateTime.now(),    // The date that will be picked initially by default
                                                                  firstDate : DateTime.now(),    //The earliest date that can be picked          
                                                                  lastDate: DateTime.now().add(const Duration(days:30))   //the last date that can be picked  - can be changed according to preference
                                                                        ).then((DateTime pickedDate) {    
                                                                            /*Since it returns a Future - .then() is used to take the value
                                                                            returned by the Future and if it is not null, rebuild to see changes and set chosenDate as pickedDate
                                                                            */
                                                                            if (pickedDate ==null) {
                                                                              return;
                                                                              }
                                                                            rebuild((){});
                                                                            chosenDate = pickedDate;
                                                                            // setState(() {
                                                                            //  chosenDate = pickedDate;
                                                                            //         });
                                                                       }
                                                                       )  
                                                      ),
                                                  
                                                  const SizedBox(width: 10),
                                                  
                                                  Text(    // If chosenDate is not null, then this text widget displays the date picked in the datePicker
                                                    chosenDate == null ? 'No date chosen!' : DateFormat('yyyy-MM-dd').format(chosenDate),
                                                    style: const TextStyle( color: Color.fromRGBO(92, 6, 50, 1.0),
                                                                            fontWeight : FontWeight.bold,
                                                                          ),
                                                     )
                                                  ],
                                              ),
                                              
                                              const SizedBox(height: 20),
                                              
                                              //Button used to submit the description and date as a todo
                                              RaisedButton(
                                                  child: Text('Submit',style: TextStyle(color: Colors.white,)),
                                                  color: const Color.fromRGBO(92, 6, 50, 1.0),
                                                  onPressed: () {
                                                    final String desc = _descController.text;   //used to retrieve the text associated the _descController (Add Todo description)
                                                    formattedDate = DateFormat('yyyy-MM-dd').format(chosenDate);
                                                    if (formattedDate == null || desc == null) {    // Used as a validation technique to check that the date and desc are not empty
                                                      return;
                                                    }
                                                    _descController.clear();  //After the text is retrieved, the text editing controller is cleared so as to not affect future inputs
                                                    final Todo todo = Todo(desc, formattedDate);
                                                    _todoBloc.add(AddTodoEvent(todo));   // the AddTodoEvent is added to the bloc 
                                                    _calendarController.setSelectedDay(chosenDate);   
                                                    /* if the date chosen in the datePicker is different from the selectedDay on the 
                                                    table calendar - the selectedDate is changed accordingly*/
                                                    formattedDate = null;
                                                    chosenDate = null;
                                                    // setState(() {
                                                    //   chosenDate = null;
                                                    //   formattedDate = null;
                                                    // });
                                                    Navigator.pop(context);
                                                  }
                                                )
                                            ],
                                          )
                                        )
                                      ),
                                    );
                                  }
                                  )
                                )
                        ]
                      ),
                    Container()
                  ],
                ),
              );
            } 
            
            else if (state is GetTodoState) {
              
              todayList = state.todayList;   
              /*If the state is an instance of GetTodoState, then the list of todos corresponding to the 
              date selected on the table calendar is retrieved as a list
              */
              return Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        TableCalendar(
                        calendarController: _calendarController,
                        onDaySelected: (DateTime date, List<dynamic> events) {
                          // setState(() {
                          //   today = DateFormat('yyyy-MM-dd').format(date);
                          // });
                          today = DateFormat('yyyy-MM-dd').format(date);
                          _todoBloc.add(GetTodoEvent(today));
                        }),
                    
                    const SizedBox(height: 10),
                    
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                              color: const Color.fromRGBO(92, 6, 50, 1.0),
                              child: Text('Add a todo', style: TextStyle(color: Colors.white)),
                              onPressed: () => 
                              showDialog<dynamic>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (BuildContext context,Function rebuild) {
                                      return AlertDialog(
                                        title: const Text('Add a new Todo',style: TextStyle(color: Color.fromRGBO(92, 6, 50, 1.0)),),
                                        content: SingleChildScrollView(
                                            child: Column(
                                          children: <Widget>[
                                            TextFormField(
                                              style: const TextStyle(color: Color.fromRGBO(92, 6, 50, 1.0),
                                                  fontWeight: FontWeight.bold),
                                              decoration: 
                                              const InputDecoration(labelText:'Enter the description here',
                                                                    labelStyle: TextStyle(color: Color.fromRGBO(92, 6, 50, 1.0)),
                                                                    fillColor: Color.fromRGBO(92, 6, 50, 1.0),
                                                                    icon:  Icon(Icons.description, color: Color.fromRGBO(92, 6, 50, 1.0),),
                                              focusColor: Color.fromRGBO(92, 6, 50, 1.0),
                                              focusedBorder:UnderlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(92, 6, 50, 1.0)),),
                                              ),
                                              controller: _descController,
                                            ),
                                            
                                            const SizedBox(height: 20),
                                            Row(
                                              children: <Widget>[
                                                RaisedButton(
                                                    child: Text('Choose Date',style: TextStyle(color: Colors.white),),
                                                    color: const Color.fromRGBO(92, 6, 50, 1.0),
                                                    onPressed: () =>
                                                        showDatePicker(
                                                          context : context,
                                                          initialDate : DateTime.now(),
                                                          firstDate : DateTime.now(),
                                                          lastDate: DateTime.now().add(const Duration(days:30))
                                                          ).then((DateTime pickedDate) {
                                                          if (pickedDate == null) {
                                                            return;
                                                          }
                                                          rebuild(() {});
                                                          // setState(() {
                                                          //   chosenDate =
                                                          //       pickedDate;
                                                          // });
                                                          chosenDate = pickedDate;
                                                        }
                                                        )
                                                      ),
                                                
                                                const SizedBox(width: 10),
                                                
                                                Text(
                                                  chosenDate == null ? 'No date chosen!' : DateFormat('yyyy-MM-dd').format(chosenDate),
                                                  style: const TextStyle( color: Color.fromRGBO(92, 6, 50, 1.0),
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                )
                                              ],
                                            ),
                                            
                                            const SizedBox(height: 20),
                                            
                                            RaisedButton(
                                                child: Text('Submit', style: TextStyle( color: Colors.white,)),
                                                color: const Color.fromRGBO(92, 6, 50, 1.0),
                                                onPressed: () {
                                                  final String desc = _descController.text;
                                                  formattedDate = DateFormat('yyyy-MM-dd').format(chosenDate);
                                                  if (formattedDate == null || desc == null) {
                                                    return;
                                                  }
                                                  _descController.clear();
                                                  final Todo todo = Todo(desc, formattedDate);
                                                  _todoBloc.add(AddTodoEvent(todo));
                                                  setState(() {
                                                    todayList = state.todayList;
                                                  });
                                                  _calendarController.setSelectedDay(chosenDate);
                                                  chosenDate = null;
                                                  formattedDate = null;
                                                  // setState(() {
                                                  //   chosenDate = null;
                                                  //   formattedDate = null;
                                                  // });
                                                  Navigator.pop(context);
                                                })
                                          ],
                                        )),
                                      );
                                    });
                                  }))
                        ]),
                    Expanded(
                        child: ListView.builder(    //used to build the widget that renders the list of todos for the selected day
                            itemCount: todayList.length,
                            itemBuilder: (BuildContext context, int index) {
                              todayList = state.todayList;   
                              return Card(
                                  margin: const EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                         borderRadius : BorderRadius.circular(10.0)),
                                  color: const Color.fromRGBO(92, 6, 50, 1.0),
                                  child: 
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      crossAxisAlignment : CrossAxisAlignment.center,
                                      mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          (index + 1).toString() + '.',
                                          style: TextStyle(color: Colors.white),
                                            ),
                                        
                                        const SizedBox(width: 10,),
                                        
                                        Container(
                                            width: 160,
                                            child: Text(todayList[index].description, style: TextStyle(color: Colors.white),)
                                            ),
                                        
                                        const SizedBox(width: 5),
                                        
                                        Checkbox(   //used to render a checkbox to update the completion status of todo items
                                            activeColor: Colors.white,
                                            checkColor: Color.fromRGBO(92, 6, 50, 1.0),
                                            value: todayList[index].isCompleted,   // The default value is the existing status of completion
                                            onChanged: (value) {
                                              _todoBloc.add(CompleteTodoEvent( todayList[index].date, index, value));   //the CompleteTodoEvent is sent to the bloc
                                              setState(() {
                                                todayList = state.todayList;   //the list is updated and the widget is rebuilt
                                              });
                                            }
                                            ),
                                        
                                        Align(    //used to delete a todo item from the list
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                            icon: Icon(Icons.delete,color: Colors.white),
                                            disabledColor: Colors.white,
                                            onPressed: () {
                                                _todoBloc.add(DeleteTodoEvent(todayList[index].date,index));     //the DeleteTodoEvent is called
                                                setState(() {
                                                  todayList = state.todayList;
                                                });
                                              },
                                            )),
                                        
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: Icon(Icons.edit, color: Colors.white),
                                              disabledColor: Colors.white,
                                              onPressed: () {   // A dialog box is used to update the description of the items
                                                
                                                showDialog<dynamic>(
                                                    context: context,
                                                    builder: (BuildContext context) =>
                                                        AlertDialog(
                                                            title: const Text( 'Update item', style: TextStyle(color: Color.fromRGBO( 92,6,50,1),fontWeight:FontWeight.bold)),
                                                            content: SizedBox(
                                                              height: 150,
                                                              child: Column(
                                                                mainAxisAlignment : MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  TextFormField(
                                                                    autofocus : true,
                                                                    style: const TextStyle(color: Color.fromRGBO(92, 6,50,1)),
                                                                    controller : _updateController,
                                                                    decoration: const InputDecoration(labelText:'Update a todo item'),
                                                                  ),
                                                                  
                                                                  Row(
                                                                    mainAxisAlignment : MainAxisAlignment.spaceAround,
                                                                    children: <Widget>[
                                                                      RaisedButton(
                                                                          color: const Color.fromRGBO(92,6,50,1),
                                                                          child: const Text('Submit'),
                                                                          onPressed:() {
                                                                            final String desc = _updateController.text;
                                                                            final String chosenDate = todayList[index].date;
                                                                            if (chosenDate == null || desc == null) {
                                                                              return;
                                                                            }
                                                                            _updateController.clear();
                                                                           final Todo todo = Todo(desc, chosenDate);
                                                                            _todoBloc.add(UpdateTodoEvent(chosenDate, index,todo));   //The UpdateTodoEvent is sent to the bloc 
                                                                            setState(() {
                                                                              todayList = state.todayList;
                                                                            });
                                                                           Navigator.pop(context);
                                                                          }
                                                                        ),
                                                                      RaisedButton(
                                                                          color: const Color.fromRGBO(92,6,50,1),
                                                                          child: const Text('Cancel'),   
                                                                          onPressed: () =>
                                                                              Navigator.pop(context))
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          )
                                                        );
                                              },
                                            ))
                                      ],
                                    ),
                                  ));
                            }))
                  ]));
            }
            else
            return Container();
          }),
      resizeToAvoidBottomPadding: false,   //used to avoid rendering issues when the keyboard pops up 
    );
  }
}
