import 'package:barber_app/clientScreens/clientProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clientCheckInScreen.dart';
// Helpers
import 'package:barber_app/helpers/auth.dart';
import '../helpers/globalVariables.dart';

class ClientHomeScreen extends StatefulWidget {
  ClientHomeScreen(
      {this.auth,
      this.onSignOut,
      this.businessCode,
      this.businessId,
      this.clientId});
  final VoidCallback onSignOut;
  final BaseAuth auth;
  final String businessCode;
  final String businessId;
  final String clientId;

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
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
      drawer: clientDrawerWidget(widget.clientId),
      appBar: AppBar(
        title: Text('Client Screen'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout'),
            onPressed: _signout,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 6,
              child: ListTile(
                title: Text(
                  'Primary Barber Shop',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
                ),
                contentPadding: EdgeInsets.all(10.0),
                subtitle: Text(
                  '${widget.businessCode}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Container(
              height: 200.0,
              child: Card(
                elevation: 7,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Favorites',
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.w700),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                        ),
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Container(
                height: 375.0,
                child: Card(
                  elevation: 7,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                      Text(
                        'Barbers',
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        height: 275.0,
                        margin: EdgeInsets.all(10.0),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection(
                                    'Owner/$ownerId/Businesses/${widget.businessId}/Employees')
                                .where('isAvailable', isEqualTo: true)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return new Center(
                                      child: new CircularProgressIndicator());
                                default:
                                  return snapshot.data.documents.length > 0
                                      ? ListView(
                                          children: snapshot.data.documents
                                              .map((document) {
                                          return Column(
                                            children: <Widget>[
                                              Container(
                                                height: 100.0,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(15.0),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            '${document['firstName']}, ${document['lastName'][0]}.',
                                                            style: TextStyle(color: Colors.grey[600],
                                                                fontSize: 20.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 8.0),
                                                          ),
                                                          Text(
                                                            'EST ${document['availableIn']}m',
                                                            style: TextStyle(color: Colors.black,
                                                                fontSize: 16.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 120,
                                                      alignment:
                                                          Alignment.center,
                                                      child: RaisedButton(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30.0)),
                                                        color: Colors
                                                            .lightBlue[400],
                                                        child: Text('Check In',
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                        onPressed: () {},
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.black,
                                                height: 3,
                                              )
                                            ],
                                          );
                                        }).toList())
                                      : Center(
                                          child: Text('No Barbers Available'),
                                        );
                              }
                            }),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget clientDrawerWidget(String clientId) {
    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('Clients')
              .where('id', isEqualTo: '$clientId')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Center(child: new CircularProgressIndicator());
              default:
                return ListView(
                    children: snapshot.data.documents.map((document) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          '${document['firstName']}, ${document['lastName']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Divider(
                        height: 20,
                        color: Colors.black,
                      ),
                      ListTile(
                        title: Text(
                          'My Check Ins',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClientCheckInScreen()));
                        },
                      ),
                      ListTile(
                        title: Text(
                          'My Profile',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClientProfileScreen()));
                        },
                      ),
                      Divider(
                        height: 8,
                        color: Colors.grey,
                      ),
                      ListTile(
                        title: Text(
                          'Logout',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: _signout,
                      ),
                    ],
                  );
                }).toList());
            }
          }),
    );
  }
}
