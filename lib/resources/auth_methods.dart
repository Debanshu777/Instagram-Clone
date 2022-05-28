import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          userName.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        //register user
        UserCredential creds = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print(creds.user!.uid);

        //Uplaoding photo
        String phtotoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        // saving to database
        await _firestore.collection('users').doc(creds.user!.uid).set({
          'username': userName,
          'uid': creds.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
          'photoUrl': phtotoUrl,
          'createdOn': DateTime.now(),
          'updatedOn': DateTime.now(),
          'lastSeen': DateTime.now(),
        });
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
}
