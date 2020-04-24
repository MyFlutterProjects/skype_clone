import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/models/models.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/call_methods.dart';
import 'package:skype_clone/screens/callScreens/pickup/pickup_screen.dart';

class PickUpLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickUpLayout({ this.scaffold});
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
      return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: userProvider.getUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data != null) {
                Call call = Call.fromMap(snapshot.data.data);
                print("de ${call.hasDialled}");
                if (!call.hasDialled) {
                  return PickUpScreen(call: call);
                }
              }
              return scaffold;
            },
          )
    : Scaffold( 
      body: Center(  
        child: CircularProgressIndicator(),
      ),
    );
  }
}