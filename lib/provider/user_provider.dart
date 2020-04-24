import 'package:flutter/cupertino.dart';
import 'package:skype_clone/models/models.dart';
import 'package:skype_clone/resources/firebase_repository.dart';

class UserProvider with ChangeNotifier { 
  User _user;
  FirebaseRepository _firebaseRepository = FirebaseRepository();

  User get getUser => _user;

  void refreshUser() async {  
    User user = await _firebaseRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }
}