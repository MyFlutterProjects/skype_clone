import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/enum/user_state.dart';
import 'package:skype_clone/models/models.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/utils/utils.dart';

class FirebaseMethods {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignin = GoogleSignIn();
  static final Firestore _firestore = Firestore.instance;
  User user;
  StorageReference _storageReference;
  static final CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);
  final CollectionReference _messageCollection = _firestore.collection(MESSAGES_COLLECTION);
  

  
 
 Future<FirebaseUser> getCurrentUser() async {
   FirebaseUser currentUser;
   currentUser = await _auth.currentUser();
   return currentUser;
 }

 Future<User> getUserDetails() async { 
   FirebaseUser currentUser = await getCurrentUser();
   DocumentSnapshot documentSnapshot = await _userCollection.document(currentUser.uid).get();
   return User.fromMap(documentSnapshot.data);
   }

   Future<User> getUserDetailsById(id) async { 
    try { 
       DocumentSnapshot documentSnapshot = await _userCollection.document(id).get();
       return User.fromMap(documentSnapshot.data);
    } catch(e) {
      print(e);
      return null;
    }
   }

 Future<FirebaseUser> signin() async {
   GoogleSignInAccount _signInAccount = await _googleSignin.signIn();
   GoogleSignInAuthentication _signInAuthentication = await _signInAccount.authentication;

   final AuthCredential credential = GoogleAuthProvider.getCredential( 
     idToken: _signInAuthentication.idToken, 
     accessToken: _signInAuthentication.accessToken
     );

     AuthResult authResult = await _auth.signInWithCredential(credential);
     FirebaseUser  user = authResult.user;
     return user;

 }

 Future<bool> authenticateUser(FirebaseUser user) async { 
   QuerySnapshot result = await _userCollection
   .where(EMAIL_FIELD, isEqualTo: user.email)
   .getDocuments();

   final List<DocumentSnapshot> docs = result.documents;
   // if user is registered then length of list > 0 or else less than 0.
   return docs.length == 0 ? true : false;  // not yet registered then registered
 } 

 Future<void> addDataToDb(FirebaseUser currentUser) async { 
   String username = Utils.getUsername(currentUser.email);

   user = User( 
     uid: currentUser.uid,
     email: currentUser.email,
     name: currentUser.displayName,
     profilePhoto: currentUser.photoUrl,
     username: username

   );

  _userCollection
   .document(currentUser.uid)
   .setData(user.toMap(user));
 }

 Future<void> signOut() async { 
   await _googleSignin.disconnect();
   await _googleSignin.signOut();
   return await _auth.signOut();
 }

 void setUserState({ @required String userId, @required UserState userState}) {
   int stateNum = Utils.stateToNum(userState);
   _userCollection.document(userId)
   .updateData({
     "state": stateNum,
     });
 }

   Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.document(uid).snapshots();

  
  Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {  
    List<User> userList = List<User>();

    QuerySnapshot querySnapshot = await _userCollection.getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid)
         userList.add(User.fromMap(querySnapshot.documents[i].data));
    }
    return userList;

  }


  Future<void> addMessageToDb(Message message, User sender, User receiver)  async {
    var map = message.toMap();

    await _messageCollection
    .document(message.senderId)
    .collection(message.receiverId)
    .add(map);
    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    // for the receiver 
     return await _messageCollection
    .document(message.receiverId)
    .collection(message.senderId)
    .add(map);

  }

  DocumentReference  getContactsDocument({String of, String forContact}) => 
  _userCollection
  .document(of)
  .collection(CONTACTS_COLLECTION)
  .document(forContact);

 

  addToContacts({ String senderId, String receiverId}) async { 
     Timestamp currentTime = Timestamp.now();
     await addToSendersContacts(senderId, receiverId, currentTime);

    
  }

  Future<void> addToSendersContacts( 
    String senderId,
    String receiverId,
    currentTime, 
  ) async {  
    DocumentSnapshot senderSnaphot = 
    await getContactsDocument(of: senderId, forContact: receiverId).get();
    if(!senderSnaphot.exists) {  
      Contact receiverContact = Contact(  
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      getContactsDocument(of: senderId, forContact: receiverId)
      .setData(receiverMap);
    }
    
  }

   Future<void> addToReceiverContacts( 
     String senderId,
    String receiverId,
    currentTime, 
  ) async {  
    DocumentSnapshot receiverSnaphot = 
    await getContactsDocument(of: receiverId, forContact: senderId).get();
    if(!receiverSnaphot.exists) {  
      Contact senderContact = Contact(  
        uid: receiverId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      getContactsDocument(of: receiverId, forContact: senderId).setData(senderMap);
    }
    
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
     .document(userId)
     .collection(CONTACTS_COLLECTION)
     .snapshots();
  
  Stream<QuerySnapshot> fetchLastMessageBetween({ @required String senderId,  @required String receiverId}) 
   => _messageCollection
   .document(senderId)
   .collection(receiverId)
   .orderBy(TIMESTAMP_FIELD).snapshots();

  Future<String> uploadImageToStorage(File image) async {
   try { 
      _storageReference = FirebaseStorage.instance
      .ref()
      .child('${DateTime.now().millisecondsSinceEpoch}');

      StorageUploadTask _storageUploadTask = _storageReference.putFile(image);

      var url = await (await _storageUploadTask.onComplete).ref.getDownloadURL();

      return url;
   } catch(e) {
     print(e);
     return null;
   }
  }
  void setImageMsg(String url, String receiverId, String senderId) async  {
    Message _message;
    _message = Message.imageMessage( 
      message: "IMAGE",
      receiverId: receiverId,
      senderId: senderId,
      photoUrl: url,
      timestamp: Timestamp.now(),
      type: 'image',

    );

    var map = _message.toImageMap();
    // set image to db 
     await _messageCollection
    .document(_message.senderId)
    .collection(_message.receiverId)
    .add(map);

    // for the receiver 
     await _messageCollection
    .document(_message.receiverId)
    .collection(_message.senderId)
    .add(map);

  }

  void uploadImage(File image,String receiverId, String senderId,  ImageUploadProvider imageUploadProvider) async {
    imageUploadProvider.setToLoading();
    String url = await uploadImageToStorage(image);

    // hide loading 
    imageUploadProvider.setToIdle();
    
    setImageMsg(url, receiverId, senderId);

    } 


}