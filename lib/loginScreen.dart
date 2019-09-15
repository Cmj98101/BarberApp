import 'package:flutter/material.dart';

// Helpers
import 'helpers/auth.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen(
      {this.auth,
      this.onSignedInAsUser,
      this.onSignedInAsAdmin,
      this.onSignedInAsOwner,
      this.onSignUpClient,
      this.onSignedInAsEmployee});
  final BaseAuth auth;
  final VoidCallback onSignedInAsUser;
  final VoidCallback onSignedInAsAdmin;
  final VoidCallback onSignedInAsOwner;
  final VoidCallback onSignUpClient;
  final VoidCallback onSignedInAsEmployee;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String _email;
  String _password;

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
        List account =
            await widget.auth.signInWithEmailAndPassword(_email, _password);
        if (account[0] == 'Owner') {
          widget.onSignedInAsOwner();
        } else if (account[0] == 'BusinessOwner') {
          widget.onSignedInAsAdmin();
        }  else if (account[0] == 'Employee') {
          widget.onSignedInAsEmployee();
        }else if (account[0] == 'Client') {
          widget.onSignedInAsUser();
        }
      } catch (error) {
        print('Error Validating Sign In: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
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
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) => value.isEmpty
                              ? 'Password field can\'t be Emtpy'
                              : null,
                          onSaved: (value) => _password = value,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                        ),
                        RaisedButton(
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          onPressed: validateAndSubmit,
                        ),
                        FlatButton(
                          child: Text(
                            'Don\'t have an account Signup!',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0),
                          ),
                          onPressed: () {
                            widget.onSignUpClient();
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
