import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

import '../models/User.dart';

class UserProvider with ChangeNotifier {
  User _user = User(
    username: "",
    uid: "uid",
    photoUrl:
        'https://images.unsplash.com/photo-1653994279745-1d38211a1b70?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=800&q=60',
    email: "email",
    bio: "bio",
    followers: [],
    following: [],
    createdOn: Timestamp.now(),
    lastSeen: Timestamp.now(),
    updatedOn: Timestamp.now(),
  );
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
