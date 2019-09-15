import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Helpers
import '../helpers/auth.dart';
import '../helpers/globalVariables.dart';

class EditEmployeeProfileScreen extends StatefulWidget {
  EditEmployeeProfileScreen(
      {this.auth,
      this.businessId,
      this.employeeId,
      this.firstName,
      this.lastName});
  final BaseAuth auth;
  final String businessId;
  final String employeeId;
  final String firstName;
  final String lastName;
  @override
  _EditEmployeeProfileScreenState createState() =>
      _EditEmployeeProfileScreenState();
}

class _EditEmployeeProfileScreenState extends State<EditEmployeeProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final formKey = GlobalKey<FormState>();

  String _firstName;
  String _lastName;
  String stateText;
  bool mondayActive = false;
  TextEditingController _firstNameTFController = TextEditingController();
  TextEditingController _lastNameTFController = TextEditingController();

  _unsuccessfullSnackBar(String content) {
    final snackBar = SnackBar(
      content: Text(
        '$content',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
      ),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.red,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _successfullSnackBar(String content) {
    final snackBar = SnackBar(
      content: Text(
        '$content',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        widget.auth.editEmployee(
            widget.businessId, widget.employeeId, _firstName, _lastName);
        _successfullSnackBar('Successfully updated employee');
        Navigator.pop(context);
      } catch (error) {
        print('ERROR could not edit employee: $error');
        _unsuccessfullSnackBar('Failed to update employee');
      }
    }
  }

  // DateTime startTime = DateTime.parse('$start').toLocal();
  // DateTime endTime = DateTime.parse('$end').toLocal();
  // var formattedStartTime = DateFormat('h:mm:ss a').format(startTime);
  // var formattedEndTime = DateFormat('h:mm:ss a').format(endTime);

  // print(formattedStartTime);
  // print(formattedEndTime);

  @override
  void dispose() {
    super.dispose();
    _firstNameTFController.dispose();
    _lastNameTFController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Employee Profile'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(12),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _firstNameTFController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) =>
                          value.isEmpty ? 'First name can\'t be Emtpy' : null,
                      onSaved: (value) => _firstName = value,
                    ),
                    TextFormField(
                      controller: _lastNameTFController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) =>
                          value.isEmpty ? 'Last name can\'t be Emtpy' : null,
                      onSaved: (value) => _lastName = value,
                    ),
                    Container(
                        height: 300,
                        color: Colors.yellow,
                        child: StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance
                                .collection(
                                    '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${widget.employeeId}/Availability/')
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return new Center(
                                      child: new CircularProgressIndicator());
                                default:
                                  return ListView(
                                      children: snapshot.data.documents
                                          .map((document) {
                                    return Column(
                                      children: <Widget>[
                                        Card(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                  color: Colors.green,
                                                  padding: EdgeInsets.only(
                                                      left: 15,
                                                      top: 15,
                                                      bottom: 15),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text('Monday'),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20),
                                                      ),
                                                      Switch(
                                                        onChanged: (value) {
                                                          Map<String, Object>
                                                              data = {
                                                            'isAvailable': value
                                                          };
                                                          
                                                            try {
                                                              Firestore.instance
                                                                  .document(
                                                                      '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${widget.employeeId}/Availability/${document.documentID}')
                                                                  .updateData(
                                                                      data);
                                                            } catch (error) {
                                                              print(
                                                                  'ERROR updating ISAVAILABLE: $error');
                                                            }
                                                            
                                                          
                                                        },
                                                        value: document['isAvailable'],
                                                      )
                                                    ],
                                                  )),
                                              Container(
                                                color: Colors.red,
                                                child: Row(
                                                  children: <Widget>[
                                                    FlatButton(
                                                      child: Text('time'),
                                                      onPressed: () {},
                                                    ),
                                                    Text('-'),
                                                    FlatButton(
                                                      child: Text('time'),
                                                      onPressed: () {},
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList());
                              }
                            })),
                    Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                    ),
                    RaisedButton(
                        child: Text(
                          'Time Available',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onPressed: () {
                          // showTimePicker(context);
                        }),
                    RaisedButton(
                        child: Text(
                          'Save Employee',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onPressed: validateAndSubmit),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void bottom() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            child: Center(
              child: Text('Hello'),
            ),
          );
        });
  }
}
