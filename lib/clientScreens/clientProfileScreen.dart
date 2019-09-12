import 'package:flutter/material.dart';

class ClientProfileScreen extends StatefulWidget {
  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Profile'),),);
  }
}
