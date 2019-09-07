import 'package:flutter/material.dart';
import 'package:dashy/models/todo.dart';
import 'package:dashy/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'home_page.dart';
import 'dashboard.dart';

class MainPage extends StatefulWidget{
  MainPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);


  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _MainPage();
}

class _MainPage extends State<MainPage>{
  int _selectedIndex = 0;
  Query _todoQuery;

  List<Todo> _todoList;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<Event> _onTodoUploadedSubscription;

  @override
  void initState(){
    super.initState();
    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);

    _onTodoUploadedSubscription = _todoQuery.onValue.listen(_onTodoLoaded);
  }

  _onTodoLoaded(Event event){
    print("Todo Loaded for the first time");
    var value = event.snapshot.value;
    _onTodoUploadedSubscription.cancel();
    print(value);

    value.forEach((key,value){
      print('${key}: ${value}');
//      _todoList.add(Todo.fromValue(key, value));
    });
  }

  @override
  Widget build(BuildContext context) {
    var function;
    if(_selectedIndex == 0){
      function = DashBoard();
    }else if(_selectedIndex == 1){
//      function = Goals();
      function =  new HomePage(
        userId: widget.userId,
        auth: widget.auth,
        onSignedOut: widget.onSignedOut,
        todoList: _todoList,
      );
    }else{
    print("Logging Out");
    _signOut();
    }

    return Scaffold(
      body: function,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home),  title: Text('Home'), backgroundColor: Colors.greenAccent),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), title: Text('To-Do')),
          BottomNavigationBarItem(icon: Icon(Icons.do_not_disturb), title: Text('Log-Out')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blueAccent,
        onTap: _pushSaved,
      ),
    );
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void _pushSaved(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}