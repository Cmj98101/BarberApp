import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adminEmployeesScreen.dart';
import 'package:intl/intl.dart';
// Helpers
import 'package:barber_app/helpers/auth.dart';
import '../helpers/globalVariables.dart';

class AdminHomeScreen extends StatefulWidget {
  AdminHomeScreen(
      {this.auth, this.onSignOut, this.barberShopCode, this.businessId});
  final VoidCallback onSignOut;
  final BaseAuth auth;
  final String barberShopCode;
  final String businessId;
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<String> timeAvailable = [];
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  String closingTime = '9:30';
  String openingTime = '8:00';
  String time;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        drawer: adminDrawerWidget(),
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: Text('Logout'),
              onPressed: _signout,
            )
          ],
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Admin Screen',
            style: TextStyle(color: Colors.black),
          ),
          bottom: TabBar(
            indicatorColor: Colors.black,
            controller: _tabController,
            labelStyle: TextStyle(color: Colors.green),
            tabs: <Widget>[
              Tab(
                  icon: Icon(
                Icons.monetization_on,
                color: _tabController.index == 0 ? Colors.green : Colors.grey,
              )),
              Tab(
                  icon: Icon(
                Icons.people,
                color: _tabController.index == 1 ? Colors.blue : Colors.grey,
              )),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Icon(Icons.directions_car),
            Icon(Icons.directions_boat),
          ],
        ),
      ),
    );
  }

  Widget adminDrawerWidget() {
    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('Owner/$ownerId/Businesses/')
              .where('barberShopCode', isEqualTo: '${widget.barberShopCode}')
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
                          '${document['businessName']}',
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
                          'Employees',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminEmployeesScreen(
                                        auth: widget.auth,
                                        businessId: '${document['id']}',
                                      )));
                        },
                      ),
                      ListTile(
                        title: Text(
                          'Analytics',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text(
                          'Queue',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text(
                          'Owner',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text(
                          'Settings',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          timeAvailable.clear();
                          for (var i = 0; i < 4; i++) {
                            DateTime now = DateTime.parse("2018-08-16 22:00:00").toLocal();
                            
                            
                            var addedTime = now.add(Duration(minutes: 15 * i));
                            var time = DateFormat('h:mm:ss a').format(addedTime);
                            timeAvailable.add('$time');
                            
                          }
                          print(timeAvailable);

                          
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
