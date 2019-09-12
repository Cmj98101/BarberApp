import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/globalVariables.dart';

abstract class BaseOwner {
  Future<void> addBusiness(String businessName, String firstName,
      String lastName, String email, String password, String barberShopCode);
}

class Owner implements BaseOwner {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Future<void> addBusiness(
      String businessName,
      String firstName,
      String lastName,
      String email,
      String password,
      String barberShopCode) async {
    FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;

    Map<String, Object> userData = {
      'businessName': businessName,
      'businessOwner': true,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'id': '${user?.uid}',
      'dateCreated': DateTime.now(),
      'barberShopCode': barberShopCode,
    };
    try {
      _db
          .collection('/Owner/$ownerId/Businesses')
          .document('$barberShopCode')
          .setData(userData);
      print('Successfully Added Business');
    } catch (error) {
      print('Failed to add business');
    }
  }
}
