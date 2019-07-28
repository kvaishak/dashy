import 'package:flutter/material.dart';
import 'package:flutter_login_demo/services/authentication.dart';
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
          BottomNavigationBarItem(icon: Icon(Icons.assignment), title: Text('Goals')),
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