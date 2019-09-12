import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/globalVariables.dart';
import 'addBusinessScreen.dart';
import 'businessDetailsScreen.dart';
// Helpers
import '../helpers/auth.dart';
import '../helpers/owner.dart';

class OwnerHomeScreen extends StatefulWidget {
  OwnerHomeScreen({this.auth, this.owner, this.onSignOut});
  final BaseAuth auth;
  final BaseOwner owner;
  final VoidCallback onSignOut;
  @override
  _OwnerHomeScreenState createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  void _signout() async {
    try {
      await widget.auth.signOut();
      widget.onSignOut();
    } catch (error) {
      print('Error Signing Out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Owner Screen'), actions: <Widget>[
        FlatButton(
          child: Text('Logout'),
          onPressed: _signout,
        ),
      ]),
      body: customerList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddBusinessScreen(
                        owner: widget.owner,
                      )));
        },
      ),
    );
  }
}

Widget customerList() {
  return Center(
    child: Container(
      margin: EdgeInsets.all(12.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('/Owner/$ownerId/Businesses')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return ListView(
                children: snapshot.data.documents.map((document) {
                  return Card(
                    elevation: 6.0,
                    child: ListTile(
                      title: Text('${document['businessName']}'),
                      subtitle: Text('ID: ${document['id']}'),
                      onTap: () {
                        // TODO: Show Business Profile from Owner Profile
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BusinessDetailsScreen(
                                      businessId: document['id'],
                                    )));
                      },
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    ),
  );
}
