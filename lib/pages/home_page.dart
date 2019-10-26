import 'package:flutter/material.dart';
import 'package:dashy/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dashy/models/todo.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut, this.todoList})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final List<Todo> todoList;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;
  StreamSubscription<Event> _onTodoRemovedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    //for maintaining an offline version of the data.
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    super.initState();

//    _checkEmailVerification();

    _todoList = widget.todoList != null ? widget.todoList : new List();
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);

    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _todoQuery.onChildChanged.listen(_onEntryChanged);
    _onTodoRemovedSubscription = _todoQuery.onChildRemoved.listen(_onEntryRemoved);
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify your account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    _onTodoRemovedSubscription.cancel();
    super.dispose();
  }
  _onEntryRemoved(Event event){
    var deleted = Todo.fromSnapshot(event.snapshot);
    print(deleted.subject + " removed");

    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList.removeAt(_todoList.indexOf(oldEntry));
    });
  }

  _onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] = Todo.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    var todoFromSnapShot = Todo.fromSnapshot(event.snapshot);
    print(todoFromSnapShot.key);
    bool isTodoPresent = false;

    for(var i = 0; i < _todoList.length; i++){
      if(_todoList[i].key == todoFromSnapShot.key){
        isTodoPresent = true;
        break;
      }
    }
    if(!isTodoPresent){
      setState(() {
        _todoList.add(todoFromSnapShot);
        print(event.snapshot.value);
      });
    }
  }

//  _signOut() async {
//    try {
//      await widget.auth.signOut();
//      widget.onSignedOut();
//    } catch (e) {
//      print(e);
//    }
//  }

  _addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      print(widget.userId);
      Todo todo = new Todo(todoItem.toString(), widget.userId, false);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  _updateTodo(Todo todo){
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  _deleteTodo(String todoId, int index) {
    _database.reference().child("todo").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      //removing the element in out local data will be handled by the removeEvent.
    });
  }

  _showDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Add New Todo."),
            content: new Row(
              children: <Widget>[
                new Expanded(child: new TextField(
                  controller: _textEditingController,
                  autofocus: true,
                  decoration: new InputDecoration(
                    labelText: 'todo',
                  ),
                ))
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('SAVE'),
                  onPressed: () {
                    _addNewTodo(_textEditingController.text.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }

  Widget _showTodoList() {
    if (_todoList.length > 0) {
//      return Column (
//        children : <Widget> [
//      Padding(
//      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
//    child: Column(
//    children: <Widget>[
//      Text(
//      "Todo.",
//      style: TextStyle(fontSize: 45.0),
//      ),])),   ]
//      );
      return ListView.builder(
      shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
              String todoId = _todoList[index].key;
              String subject = _todoList[index].subject;
              bool completed = _todoList[index].completed;
//            String userId = _todoList[index].userId;
              return Dismissible(
                key: Key(todoId),
                background: Container(color: Colors.red),
                onDismissed: (direction) async {
                  _deleteTodo(todoId, index);
                },
                child: ListTile(
                  title: Text(
                    subject,
                    style: TextStyle(fontSize: 20.0),
                  ),
                  trailing: IconButton(
                      icon: (completed)
                          ? Icon(
                        Icons.done_outline,
                        color: Colors.blue,
                        size: 20.0,
                      )
                          : Icon(Icons.done, color: Colors.grey, size: 20.0),
                      onPressed: () {
                        _updateTodo(_todoList[index]);
                      }),
                ),
              );
          });

    } else {
      return Center(child: Text("Start by Adding Todo.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Todo.', style: TextStyle(color: Colors.black, fontSize: 40),),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: _showTodoList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showDialog(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        )
    );
  }
}