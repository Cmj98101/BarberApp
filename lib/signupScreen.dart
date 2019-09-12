import 'package:flutter/material.dart';

// Helpers
import 'helpers/auth.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen(
      {this.auth, this.onSignedInAsUser, this.onSignUpUser, this.logInScreen});
  final BaseAuth auth;
  final VoidCallback onSignUpUser;
  final VoidCallback onSignedInAsUser;
  final VoidCallback logInScreen;

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();

  String _email;
  String _firstName;
  String _lastName;
  String _phoneNumber;
  String _password;
  String _code;

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
        print('$_email, $_password');
        // TODO: PACK ALL BUSINESS SHOPS INFO INTO LIST AND DISTRIBUTE THE DATA
        
        List account = await widget.auth.createUserWithEmailAndPassword(
            _email, _password, _firstName, _lastName, _phoneNumber, _code);
        widget.onSignedInAsUser();
        print('$account');
      } catch (error) {
        print('Error Validating Sign Up: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(16.0),
            child: Form(
                key: formKey,
                child: ListView(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email'),
                          validator: (value) => value.isEmpty
                              ? 'Email field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _email = value,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'First Name'),
                          validator: (value) => value.isEmpty
                              ? 'First name field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _firstName = value,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Last Name'),
                          validator: (value) => value.isEmpty
                              ? 'Last name field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _lastName = value,
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                          validator: (value) => value.isEmpty
                              ? 'Phone number field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _phoneNumber = value,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) => value.isEmpty
                              ? 'Password field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _password = value,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Code'),
                          validator: (value) => value.isEmpty
                              ? 'Code field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _code = value,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                        ),
                        RaisedButton(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          onPressed: validateAndSubmit,
                        ),
                        FlatButton(
                          child: Text(
                            'Already have an account Login!',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0),
                          ),
                          onPressed: () {
                            widget.logInScreen();
                          },
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
