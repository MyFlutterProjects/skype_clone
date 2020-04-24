import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skype_clone/enum/user_state.dart';
import 'package:skype_clone/models/models.dart';
import 'package:skype_clone/resources/firebase_methods.dart';
import 'package:skype_clone/utils/utils.dart';

class OnlineIndicator extends StatelessWidget {
  final String uid;
  final FirebaseMethods _authMethods = FirebaseMethods();

  OnlineIndicator({this.uid});

  getColor(int state) {
    switch(Utils.numToState(state)) {
      case UserState.offline:
       return Colors.red;
      case UserState.online:
       return Colors.green;
      default:
      return Colors.orange;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: StreamBuilder<DocumentSnapshot>( 
        stream: _authMethods.getUserStream( 
          uid: uid
        ),
        builder: (context, snapshot) {
          User user;

          if (snapshot.hasData && snapshot.data.data != null ) {
            user = User.fromMap(snapshot.data.data);
          }
          return Container( 
            height: 10,
            width: 10,
            margin: EdgeInsets.only(right: 5, top: 5),
            decoration: BoxDecoration(  
              shape: BoxShape.circle,
              color: getColor(user?.state),
            ),

          );
        },
      ),
      
    );
  }
}