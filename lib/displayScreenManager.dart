import 'package:flutter/material.dart';

// Screens
import 'loginScreen.dart';
import 'clientScreens/clientHomeScreen.dart';
import 'adminScreens/adminHomeScreen.dart';
import 'ownerScreens/ownerHomeScreen.dart';
import 'signupScreen.dart';
// import 'adminLoginScreen.dart';
// Helpers
import 'helpers/auth.dart';
import 'helpers/owner.dart';

class DisplayScreenManager extends StatefulWidget {
  DisplayScreenManager({this.auth, this.owner});
  final BaseAuth auth;
  final BaseOwner owner;
  @override
  _DisplayScreenManagerState createState() => _DisplayScreenManagerState();
}

enum AuthStatus {
  notSignedIn,
  signedInAsUser,
  signedInAsAdmin,
  signedInAsOwner,
  signUpClient, signedInAsEmployee
}

class _DisplayScreenManagerState extends State<DisplayScreenManager> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  List userData = [];
  @override
  void initState() {
    super.initState();
    try {
      widget.auth.currentUser().then((user) {
        if (user == null) {
          setState(() {
            authStatus = AuthStatus.notSignedIn;
          });
        } else if (user[0] == 'BusinessOwner') {
          setState(() {
            print('BUSINESS $user');
            userData = user;
            authStatus = AuthStatus.signedInAsAdmin;
          });
        } else if (user[0] == 'Owner') {
          setState(() {
            userData = user;
            authStatus = AuthStatus.signedInAsOwner;
          });
        } else if (user[0] == 'Client') {
          setState(() {
            userData = user;
            authStatus = AuthStatus.signedInAsUser;
          });
        } else {
          setState(() {
            authStatus = AuthStatus.notSignedIn;
          });
        }
      });
    } catch (error) {
      print('ERROR Checking currentUser DisplayScreenManager: $error');
    }
  }

  void _signedInAsUser() {
    widget.auth.currentUser().then((client) {
      setState(() {
        print(client);
        userData = client;
        print('Client: $userData');
        authStatus = AuthStatus.signedInAsUser;
      });
    });
    
  }

  void _signedInAsAdmin() {
    widget.auth.currentUser().then((admin) {
      setState(() {
        print(admin);
        userData = admin;
        print('BusinessOwner: $userData');
        authStatus = AuthStatus.signedInAsAdmin;
      });
    });
  }

  void _signedInAsOwner() {
    print('Owner $userData');
    setState(() {
      authStatus = AuthStatus.signedInAsOwner;
    });
  }
    void _signedInAsEmployee() {
    print('Employee $userData');
    setState(() {
      authStatus = AuthStatus.signedInAsEmployee;
    });
  }

  void _signUpUser() {
    print('signUP: $userData');
    setState(() {
      authStatus = AuthStatus.signUpClient;
    });
  }

  void _signedOut() {
    print('SignOut: $userData');
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        // Display Login Page / Sign Up Screen.
        return LoginScreen(
          auth: widget.auth,
          onSignedInAsUser: _signedInAsUser,
          onSignedInAsOwner: _signedInAsOwner,
          onSignedInAsAdmin: _signedInAsAdmin,
          onSignUpClient: _signUpUser,onSignedInAsEmployee: _signedInAsEmployee,
        );
      case AuthStatus.signedInAsUser:
        // Display User Screen.
        return ClientHomeScreen(
          auth: widget.auth,
          onSignOut: _signedOut,
          businessCode: userData[2],
          businessId: userData[3],
          clientId: userData[1],
        );
      case AuthStatus.signedInAsAdmin:
        // Display Admin Screen.
        return AdminHomeScreen(
          auth: widget.auth,
          onSignOut: _signedOut,
          barberShopCode: userData[2],
          businessId: userData[1],
        );
      case AuthStatus.signedInAsOwner:
        // Display Admin Screen.
        return OwnerHomeScreen(
          auth: widget.auth,
          owner: widget.owner,
          onSignOut: _signedOut,
        );
      case AuthStatus.signedInAsEmployee:
        // Display Employee Screen
        
      case AuthStatus.signUpClient:
        // Display Admin Screen.
        return SignupScreen(
          auth: widget.auth,
          onSignUpUser: _signUpUser,
          logInScreen: _signedOut,
          onSignedInAsUser: _signedInAsUser,
        );
    }
    return LoginScreen(
      auth: widget.auth,
      onSignedInAsUser: _signedInAsUser,
      onSignedInAsOwner: _signedInAsOwner,
    );
  }
}
