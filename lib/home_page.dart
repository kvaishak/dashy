import 'package:flutter/material.dart';
import 'package:flutter_login_demo/authentication.dart';
//import 'package:firebase_database/firebase_database.dart';
//import 'package:flutter_login_demo/models/todo.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}
class _HomePageState extends State<HomePage>{

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Widget _showTodoList(){
    return Center(child: Text("Hi. Your list is empty",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 30.0),));
    }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _showTodoList(),
        floatingActionButton: FloatingActionButton(
//          onPressed: () {
//            _showDialog(context);
//          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        )
    );
  }


}