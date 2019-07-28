import 'package:flutter/material.dart';

class DashBoard extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Container(
          height: 400,
          width: 400,
          alignment: Alignment.center,
          color: Colors.lightBlueAccent,
          child: Text("This is your Dashboard"),
        ),
      ),
    );
  }
}