import 'package:barber_app/helpers/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addEmployeeScreen.dart';
import 'editEmployeeProfileScreen.dart';

// Helpers
import '../helpers/globalVariables.dart';

class AdminEmployeesScreen extends StatefulWidget {
  AdminEmployeesScreen({this.auth, this.businessId});
  final BaseAuth auth;
  final String businessId;
  @override
  _AdminEmployeesScreenState createState() => _AdminEmployeesScreenState();
}

enum EmployeeOptions { edit, delete, isAvailable, notAvailable }

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: Add Employees via FloatingActionButton
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.add,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEmployeeScreen(
                      auth: widget.auth, businessId: widget.businessId),
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection(
                  '/Owner/$ownerId/Businesses/${widget.businessId}/Employees')
              .orderBy('isAvailable', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                return snapshot.data.documents.length > 0
                    ? ListView(
                        children: snapshot.data.documents.map((document) {
                          return Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Card(
                                  color: document['isAvailable'] == true
                                      ? Colors.green[300]
                                      : Colors.grey[350],
                                  elevation: 3,
                                  margin: EdgeInsets.only(
                                      left: 10, right: 10, top: 8, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(
                                          'Employee',
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 14.0),
                                          textAlign: TextAlign.left,
                                        ),
                                        subtitle: Text(
                                          '${document['lastName']}, ${document['firstName']}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.left,
                                        ),
                                        trailing:
                                            PopupMenuButton<EmployeeOptions>(
                                          icon: Icon(
                                            Icons.settings,
                                            color: Colors.black,
                                          ),
                                          onSelected: (EmployeeOptions result) {
                                            switch (result) {
                                              case EmployeeOptions.edit:
                                                // TODO: Edit Employee Feature
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditEmployeeProfileScreen(
                                                              auth: widget.auth,
                                                              businessId: widget
                                                                  .businessId,
                                                              employeeId: document
                                                                  .documentID,
                                                            )));
                                                break;
                                              case EmployeeOptions.delete:
                                                // TODO: Snackbar for completion
                                                deleteEmployee(
                                                    context,
                                                    widget.businessId,
                                                    document.documentID,
                                                    document['firstName'],
                                                    document['lastName']);
                                                break;
                                              case EmployeeOptions.isAvailable:
                                                // Todo: Employee is available
                                                Map<String, Object> data = {
                                                  'isAvailable': false
                                                };
                                                setState(() {
                                                  try {
                                                    Firestore.instance
                                                        .document(
                                                            '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${document.documentID}')
                                                        .updateData(data);
                                                  } catch (error) {
                                                    print(
                                                        'ERROR updating ISAVAILABLE: $error');
                                                  }
                                                });
                                                break;
                                              case EmployeeOptions.notAvailable:
                                                Map<String, Object> data = {
                                                  'isAvailable': true
                                                };
                                                setState(() {
                                                  try {
                                                    Firestore.instance
                                                        .document(
                                                            '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${document.documentID}')
                                                        .updateData(data);
                                                  } catch (error) {
                                                    print(
                                                        'ERROR updating ISAVAILABLE: $error');
                                                  }
                                                });
                                                break;
                                              default:
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<EmployeeOptions>>[
                                            const PopupMenuItem<
                                                    EmployeeOptions>(
                                                value: EmployeeOptions.edit,
                                                child:
                                                    Text('Employee Profile')),
                                            const PopupMenuItem<
                                                    EmployeeOptions>(
                                                value: EmployeeOptions.delete,
                                                child: Text('Delete Employee')),
                                            PopupMenuItem<EmployeeOptions>(
                                                value:
                                                    document['isAvailable'] ==
                                                            true
                                                        ? EmployeeOptions
                                                            .isAvailable
                                                        : EmployeeOptions
                                                            .notAvailable,
                                                child:
                                                    document['isAvailable'] ==
                                                            true
                                                        ? Text('Not Available')
                                                        : Text('Available')),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Column(children: <Widget>[
                                Text(
                                  'No Employees!',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                ),
                                RaisedButton(
                                  child: Text('Add Employees Now'),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddEmployeeScreen(
                                                    auth: widget.auth,
                                                    businessId:
                                                        widget.businessId)));
                                  },
                                )
                              ]),
                            ),
                          ],
                        ),
                      );
            }
          },
        ),
      ),
    );
  }

  void deleteEmployee(BuildContext context, String businessId,
      String employeeId, String firstName, String lastName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            "Are you sure you want to delete",
            textAlign: TextAlign.center,
          ),
          content: Text(
            '$firstName $lastName',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
                elevation: 5,
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
                onPressed: () {
                  widget.auth.deleteEmployee(businessId, employeeId);
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }
}
