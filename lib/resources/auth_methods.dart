import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/User.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  //Sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String userName,
    required String bio,
    required Uint8List file,
  }) async {
    String response = "Some error occured";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          userName.isNotEmpty &&
          bio.isNotEmpty) {
        //register user
        UserCredential creds = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(creds.user!.uid);

        //Uplaoding photo
        String phtotoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        // User
        model.User user = model.User(
          username: userName,
          uid: creds.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: phtotoUrl,
          createdOn: Timestamp.now(),
          updatedOn: Timestamp.now(),
          lastSeen: Timestamp.now(),
        );

        // saving to database
        await _firestore
            .collection('users')
            .doc(creds.user!.uid)
            .set(user.toJson());
        response = "User is Successfully Created";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == "invalid-email") {
        response = 'Email is not properly formated';
      } else if (err.code == 'weak-password') {
        response = 'Password should be atleast 6 character';
      }
    } catch (err) {
      response = err.toString();
    }
    return response;
  }

  //login user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String response = "Some error ocurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        response = "Signed In Successfully";
      } else {
        response = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == "user-not-found") {
        response = "User Doesn't Exist or have been deleted";
      } else if (err.code == 'wrong-password') {
        response = 'Password is incorrect';
      }
    } catch (err) {
      response = err.toString();
    }
    return response;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
