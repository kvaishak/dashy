import 'package:flutter/material.dart';
import 'package:dashy/services/authentication.dart';
import 'package:dashy/pages/root_page.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Dashy',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:new RootPage(auth: new Auth())
    );
  }
}