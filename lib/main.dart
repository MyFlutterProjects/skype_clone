import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype_clone/resources/firebase_repository.dart';
import 'package:skype_clone/screens/home_screen.dart';
import 'package:skype_clone/screens/login_secreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    FirebaseRepository _repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
 
    return MaterialApp(
      title: 'Skype clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _repository.getCurrentUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot){
          if (snapshot.hasData) {
            print('Data: ${snapshot.data.email}');
            return HomeScreen();
          } else { 
            return LoginScreen();
          }
        },
      ),
    );
  }
}
