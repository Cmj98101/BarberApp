import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/globalVariables.dart';

import 'dart:async';

abstract class BaseAuth {
  Future<List> createUserWithEmailAndPassword(String email, String password,
      String firstName, String lastName, String phoneNumber, String code);
  Future<List> signInWithEmailAndPassword(String email, String password);
  Future<List> currentUser();
  Future<void> signOut();
  Future<void> addEmployee(
      String firstName, String lastName, String businessId);
  Future<void> editEmployee(String businessId, String employeeId, String firstName, String lastName);
  Future<void> deleteEmployee(String businessId, String employeeId);
}

// Maybe implement a key/value pair system to retrieve data (MAP)r
class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _db = Firestore.instance;

  Future<List> createUserWithEmailAndPassword(
      String email,
      String password,
      String firstName,
      String lastName,
      String phoneNumber,
      String code) async {
    List userData = [];
    var businessId;

    print(userData);

    FirebaseUser user;
    Stream<QuerySnapshot> businessSnapshot = _db
        .collection('/Owner/$ownerId/Businesses/')
        .where('barberShopCode', isEqualTo: '$code')
        .snapshots();
    businessSnapshot.listen((snapshot) {
      snapshot.documents.forEach((document) async {
        print('BARBERSHOPCODE: ${document['barberShopCode']}');
        if (document.exists) {
          businessId = document.documentID;
          print('id: $businessId');
          user = (await _firebaseAuth.createUserWithEmailAndPassword(
                  email: email, password: password))
              .user;
          Map<String, Object> clientData = {
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'email': email,
            'password': password,
            'id': '${user?.uid}',
            'businessId': '$businessId',
            'dateCreated': DateTime.now(),
            'barberShopCode': code,
            'haircutDetails': ''
          };

          try {
            await _db
                .collection('Clients')
                .document('${user?.uid}')
                .setData(clientData)
                .then((value) async {
              DocumentSnapshot clientProfile = await _db
                  .collection('Clients')
                  .document('${user?.uid}')
                  .get();
              userData = [
                'Client',
                '${user?.uid}',
                clientProfile['barberShopCode']
              ];
            });
            return userData;
          } catch (error) {
            print('$error');
          }
        }
        return userData;
      });
    });

    userData = [null];

    return userData;
  }

  Future<List> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    DocumentSnapshot clientProfile =
        await _db.collection('Clients').document('${user?.uid}').get();
    DocumentSnapshot ownerProfile =
        await _db.collection('Owner').document('${user?.uid}').get();
    DocumentSnapshot businessProfile = await _db
        .collection('Owner')
        .document('$ownerId')
        .collection('Businesses')
        .document('${user?.uid}')
        .get();
    List userData = [];

    if (ownerProfile.exists) {
      var isOwner = ownerProfile['owner'];
      if (isOwner == true) {
        print('Owner Account Logged In: ${user?.uid}');
        userData = ['Owner', '${user?.uid}'];
        return userData;
      }
    } else if (businessProfile.exists) {
      var isBusinessOwner = businessProfile['businessOwner'];
      if (isBusinessOwner == true) {
        print('Business Account Logged In: ${user?.uid}');
        userData = [
          'BusinessOwner',
          '${user?.uid}',
          businessProfile['barberShopCode']
        ];
        print('AUTH: $userData');
        return userData;
      }
    } else if (clientProfile.exists) {
      print('Client Id: ${user?.uid}');
      userData = [
        'Client',
        '${user?.uid}',
        clientProfile['barberShopCode'],
        clientProfile['businessId']
      ];
      return userData;
    }
    userData = [null];
    return userData;
  }

  Future<List> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    DocumentSnapshot clientProfile =
        await _db.collection('Clients').document('${user?.uid}').get();
    DocumentSnapshot ownerProfile =
        await _db.collection('Owner').document('${user?.uid}').get();
    DocumentSnapshot businessProfile = await _db
        .collection('Owner')
        .document('$ownerId')
        .collection('Businesses')
        .document('${user?.uid}')
        .get();
    var userData = [];

    if (ownerProfile.exists) {
      var isOwner = ownerProfile['owner'];
      if (isOwner == true) {
        print('Owner Account Logged In: ${user?.uid}');
        userData = ['Owner', '${user?.uid}'];
        return userData;
      }
    } else if (businessProfile.exists) {
      var isBussinessOwner = businessProfile['businessOwner'];
      if (isBussinessOwner == true) {
        print('Business Account Logged In: ${user?.uid}');
        userData = [
          'BusinessOwner',
          '${user?.uid}',
          businessProfile['barberShopCode']
        ];
        return userData;
      }
    } else if (clientProfile.exists) {
      print('Client Id: ${user?.uid}');
      userData = [
        'Client',
        '${user?.uid}',
        clientProfile['barberShopCode'],
        clientProfile['businessId']
      ];
      return userData;
    }

    userData = [null];
    return userData;
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  Future<void> addEmployee(
      String firstName, String lastName, String businessId) async {
    Map<String, Object> employeeData = {
      'firstName': firstName,
      'lastName': lastName,
      'isAvailable': false,
      'availableIn': 0
    };

    var employeeDb = _db
        .collection('Owner')
        .document('$ownerId')
        .collection('Businesses')
        .document('$businessId')
        .collection('Employees');
    try {
      employeeDb.add(employeeData);
    } catch (error) {
      print('ERROR adding employee: $error');
    }
  }

  Future<void> editEmployee(String businessId, String employeeId, String firstName, String lastName) async {
    var employeeToEdit =
        _db.collection('/Owner/$ownerId/Businesses/$businessId/Employees');
        Map<String, Object> editedEmployeeData = {
      'firstName': firstName,
      'lastName': lastName,
      
    };
    try {
      employeeToEdit.document('$employeeId').updateData(editedEmployeeData);
    } catch (error) {
      print('ERROR editing employee: $error');
    }
  }
  Future<void> deleteEmployee(String businessId, String employeeId) async {
    var employeeToDelete =
        _db.collection('/Owner/$ownerId/Businesses/$businessId/Employees');
    try {
      employeeToDelete.document('$employeeId').delete();
    } catch (error) {
      print('ERROR deleting employee: $error');
    }
  }
}
