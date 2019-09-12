import 'package:flutter/material.dart';

// Helpers
import '../helpers/owner.dart';

class AddBusinessScreen extends StatefulWidget {
  AddBusinessScreen({this.owner});
  final BaseOwner owner;
  @override
  _AddBusinessScreenState createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final formKey = GlobalKey<FormState>();
  String _businessName;
  String _firstName;
  String _lastName;
  String _email;
  String _password;
  String _barberShopCode;

  TextEditingController _businessNameTFController = TextEditingController();
  TextEditingController _firstNameTFController = TextEditingController();
  TextEditingController _lastNameTFController = TextEditingController();
  TextEditingController _emailTFController = TextEditingController();
  TextEditingController _passwordTFController = TextEditingController();
  TextEditingController _barberShopCodeTFController = TextEditingController();

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
        widget.owner.addBusiness(
            _businessName, _firstName, _lastName, _email, _password, _barberShopCode);
        _successfullSnackBar('SUCCESSFULL: Business added!');
        _businessNameTFController.clear();
        _firstNameTFController.clear();
        _lastNameTFController.clear();
        _emailTFController.clear();
        _passwordTFController.clear();
        _barberShopCodeTFController.clear();

        await new Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      } catch (error) {
        _unsuccessfullSnackBar('FAILED: Business could not be added!');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    _businessNameTFController.dispose();
    _firstNameTFController.dispose();
    _lastNameTFController.dispose();
    _emailTFController.dispose();
    _passwordTFController.dispose();
    _barberShopCodeTFController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add new Business'),
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
                      controller: _businessNameTFController,
                      decoration: InputDecoration(labelText: 'Business Name'),
                      validator: (value) => value.isEmpty
                          ? 'Business name can\'t be Emtpy'
                          : null,
                      onSaved: (value) => _businessName = value,
                    ),
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
                    TextFormField(
                      controller: _emailTFController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value.isEmpty ? 'Email can\'t be Emtpy' : null,
                      onSaved: (value) => _email = value,
                    ),
                    TextFormField(
                      controller: _passwordTFController,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: (value) => value.isEmpty
                          ? 'Password can\'t be Emtpy'
                          : null,
                      onSaved: (value) => _password = value,
                    ),
                    TextFormField(
                      controller: _barberShopCodeTFController,
                      decoration: InputDecoration(labelText: 'Unique Code'),
                      validator: (value) => value.isEmpty
                          ? 'Barber Shop Code can\'t be Emtpy'
                          : null,
                      onSaved: (value) => _barberShopCode = value,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                    ),
                    RaisedButton(
                        child: Text(
                          'Add Business',
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
