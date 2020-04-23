import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/models.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/utils/utils.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignin = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;
  User user;
  StorageReference _storageReference;
 
 Future<FirebaseUser> getCurrentUser() async {
   FirebaseUser currentUser;
   currentUser = await _auth.currentUser();
   return currentUser;
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
   QuerySnapshot result = await firestore
   .collection(USERS_COLLECTION)
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

   firestore
   .collection(USERS_COLLECTION)
   .document(currentUser.uid)
   .setData(user.toMap(user));
 }

 Future<void> signOut() async { 
   await _googleSignin.disconnect();
   await _googleSignin.signOut();
   return await _auth.signOut();
 }
  
  Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {  
    List<User> userList = List<User>();

    QuerySnapshot querySnapshot = await firestore.collection(USERS_COLLECTION).getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid)
         userList.add(User.fromMap(querySnapshot.documents[i].data));
    }
    return userList;

  }


  Future<void> addMessageToDb(Message message, User sender, User receiver)  async {
    var map = message.toMap();

    await firestore
    .collection(MESSAGES_COLLECTION)
    .document(message.senderId)
    .collection(message.receiverId)
    .add(map);

    // for the receiver 
     return await firestore
    .collection(MESSAGES_COLLECTION)
    .document(message.receiverId)
    .collection(message.senderId)
    .add(map);

  }
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
     await firestore
    .collection(MESSAGES_COLLECTION)
    .document(_message.senderId)
    .collection(_message.receiverId)
    .add(map);

    // for the receiver 
     await firestore
    .collection(MESSAGES_COLLECTION)
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