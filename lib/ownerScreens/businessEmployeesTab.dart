import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/globalVariables.dart';

class BusinessEmployeesTab extends StatefulWidget {
  BusinessEmployeesTab({this.businessId});
  final String businessId;
  @override
  _BusinessEmployeesTabState createState() => _BusinessEmployeesTabState();
}

class _BusinessEmployeesTabState extends State<BusinessEmployeesTab> {
  @override
  Widget build(BuildContext context) {
    // TODO: Add Employees via FloatingActionButton
    return Container(
      color: Colors.red,
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection(
                '/Owner/$ownerId/Businesses/${widget.businessId}/Employees')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return ListView(
                children: snapshot.data.documents.map((document) {
                  return Container(
                    color: Colors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Card(
                          color: Colors.yellow,
                          elevation: 3,
                          margin: EdgeInsets.only(
                              left: 10, right: 10, top: 8, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  'Employee',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14.0),
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
                                trailing: employeeOptions(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}

enum EmployeeOptions { edit, delete }

Widget employeeOptions(BuildContext context) {
  return PopupMenuButton<EmployeeOptions>(
    icon: Icon(
      Icons.settings,
      color: Colors.black,
    ),
    onSelected: (EmployeeOptions result) {
      switch (result) {
        case EmployeeOptions.edit:
          // TODO: Edit Employee Feature
          print('Editing');
          break;
        case EmployeeOptions.delete:
          // TODO: Delete Employee Feature
          print('Deleting');
          break;
        default:
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<EmployeeOptions>>[
      const PopupMenuItem<EmployeeOptions>(
          value: EmployeeOptions.edit, child: Text('Edit Employee')),
      const PopupMenuItem<EmployeeOptions>(
          value: EmployeeOptions.delete, child: Text('Delete Employee')),
    ],
  );
}
