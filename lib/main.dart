import 'package:flutter/material.dart';

import 'displayScreenManager.dart';

// Helpers
import 'helpers/auth.dart';
import 'helpers/owner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: DisplayScreenManager(auth: Auth(), owner: Owner(),),
    );
  }
}

