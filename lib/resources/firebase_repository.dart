import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:skype_clone/models/models.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/resources/firebase_methods.dart';

class FirebaseRepository {
  
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<FirebaseUser> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<FirebaseUser> signIn() => _firebaseMethods.signin();

  Future<bool> authenticateUser(FirebaseUser user) => _firebaseMethods.authenticateUser(user);
  
  Future<void> addDataToDb(FirebaseUser user ) => _firebaseMethods.addDataToDb(user);

  Future<void> signOut()=> _firebaseMethods.signin();

  Future<List<User>> fetchAllUsers(FirebaseUser user) => _firebaseMethods.fetchAllUsers(user);

  Future<void> addMessageToDb(Message message, User sender, User receiver) =>
    _firebaseMethods.addMessageToDb(message, sender, receiver);

  void uploadImage({ 
    @required File image,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider,
  }) => _firebaseMethods.uploadImage(image, receiverId, senderId, imageUploadProvider);


}