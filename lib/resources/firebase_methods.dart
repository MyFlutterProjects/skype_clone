import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype_clone/models/user.dart';
import 'package:skype_clone/utils/utils.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignin = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;
  User user;
 
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
   .collection("users")
   .where("email", isEqualTo: user.email)
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
   .collection("users")
   .document(currentUser.uid)
   .setData(user.toMap(user));
 }

}