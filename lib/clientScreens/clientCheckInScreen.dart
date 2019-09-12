import 'package:flutter/material.dart';

class ClientCheckInScreen extends StatefulWidget {
  @override
  _ClientCheckInScreenState createState() => _ClientCheckInScreenState();
}

class _ClientCheckInScreenState extends State<ClientCheckInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Ins'),
      ),
      body: Container(child: Column(children: <Widget>[Container()],),),
    );
  }
}
