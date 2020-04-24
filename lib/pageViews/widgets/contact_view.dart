import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/models/models.dart';
import 'package:skype_clone/pageViews/widgets/last_message_container.dart';
import 'package:skype_clone/pageViews/widgets/online_dot_indicator.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/firebase_methods.dart';
import 'package:skype_clone/screens/chatScreen/chat_screen.dart';
import 'package:skype_clone/screens/chatScreen/widgets/chached_image.dart';
import 'package:skype_clone/widgets/custom_Tile.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final FirebaseMethods _authMethods = FirebaseMethods();
  ContactView(this.contact);
  
  

  @override
  Widget build(BuildContext context) {
     return FutureBuilder<User>( 
       future: _authMethods.getUserDetailsById(contact.uid),
       builder: (context, snapshot) {
        if (snapshot.hasData) { 
           User user = snapshot.data;
         return ViewLayout( 
           contact: user,
         );
        }
        return Center(child: CircularProgressIndicator(),);
       }
       
       
     );
  }
}

class ViewLayout extends StatelessWidget {
  final User contact;
  final FirebaseMethods _chatMethods =  FirebaseMethods();

  ViewLayout({@required this.contact});
  @override
  Widget build(BuildContext context) {
  final UserProvider userProvider = Provider.of(context);

    return CustomTile(
            mini: false,
            onTap: () => Navigator.push(context, MaterialPageRoute(  
              builder: (context) => ChatScreen(
                receiver: contact
              )
            )),
            title: Container(
              width: MediaQuery.of(context).size.width *0.70,
              child: Text( 
                contact?.name ?? "..",
                style: TextStyle(  
                  color: Colors.white,
                  fontFamily: "Arial",
                  fontSize: 19,
                ),
              ),
            ),
            subtitle: LastMessageContainer(
              stream: _chatMethods.fetchLastMessageBetween( 
                senderId: userProvider.getUser.uid,
                receiverId: contact.uid
                ),
            ),
            leading: Container( 
              constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
              child: Stack(  
                children: <Widget>[
                  CachedImage( 
                    contact.profilePhoto,
                    radius: 80,
                    isRound: true,
                  ),
                 OnlineIndicator( 
                   uid: contact.uid,)
                ],
              ),

            ),

          );
    
  }
}