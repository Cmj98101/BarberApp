import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  @override
  _AdminSettingsScreenState createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Store Hours'),
            ),
            Divider(color: Colors.black,thickness: .5,),
            ListTile(
              title: Text('Stores'),
            ),
            Divider(color: Colors.black,thickness: .5,),
          ],
        ),
      ),
    );
  }
}
