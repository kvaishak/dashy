import 'package:flutter/material.dart';

class DashBoard extends StatelessWidget{

  var hour;

  Widget build(BuildContext context) {
//    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
//        appBar: new AppBar(
//          title: new Text('Login/Sign-Up Page'),
//        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
//            _showCircularProgress(),
          ],
        ));
  }

  Widget _showBody(){
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showDate(),
              _showWish(),
//              _showPasswordInput(),
//              _showPrimaryButton(),
//              _showSecondaryButton(),
//              _showErrorMessage(),
            ],
          ),
        ));
  }


  Widget _showDate() {

    var time = DateTime.now(),
        weekArray = [
          "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
        ],
        monthArray = [
          "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
        ],
        todayDate = time.day,
        weekday = weekArray[time.weekday.toInt() - 1],
//        hour = time.hour,
        month = monthArray[time.month.toInt() - 1];
        hour = time.hour;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "$todayDate $month",
            style: TextStyle(fontSize: 45.0),
          ),
          Text("$weekday",
              maxLines: 1,
              style: TextStyle(
                  fontSize: 45.0, color: Colors.lightBlueAccent),
              textAlign: TextAlign.justify),
        ],
      ),
    );
  }

  Widget _showWish(){
    var wish ;
    if(hour < 11){
      wish = "Good Morning";
    }else if(hour < 16){
      wish = "Good Afternoon";
    }else if(hour < 21){
      wish = "Good Evening";
    }else if(hour < 24){
      wish  = "Good Night";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 60, 0.0, 0.0),
      child: Center(
        child: Container(
          child: Text(wish,  style: TextStyle(fontSize: 50, color: Colors.black), textAlign: TextAlign.justify),
        ),
      ),
    );
  }
}