import 'package:flutter/material.dart';

// Helpers
import '../helpers/auth.dart';

class AddEmployeeScreen extends StatefulWidget {
  AddEmployeeScreen({this.auth, this.businessId});
  final BaseAuth auth;
  final String businessId;
  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final formKey = GlobalKey<FormState>();

  String _firstName;
  String _lastName;

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
        widget.auth.addEmployee(_firstName, _lastName, widget.businessId);
        _successfullSnackBar('SUCCESSFULL: Employee added!');

        _firstNameTFController.clear();
        _lastNameTFController.clear();

        await new Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } catch (error) {
        print('$error');
        _unsuccessfullSnackBar('FAILED: Employee could not be added!');
      }
    }
  }

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
        title: Text('Add new Employee'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(15.0),
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
                    Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                    ),
                    RaisedButton(
                        child: Text(
                          'Add Employee',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onPressed: validateAndSubmit)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
