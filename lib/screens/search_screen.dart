import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:skype_clone/models/user.dart';
import 'package:skype_clone/resources/firebase_repository.dart';
import 'package:skype_clone/screens/chatScreen/chat_screen.dart';
import 'package:skype_clone/utils/universal_variables.dart';
import 'package:skype_clone/widgets/custom_Tile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseRepository _repository = FirebaseRepository();

  List<User> userList;
  String query ="";

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository.getCurrentUser().then((FirebaseUser user) {
      _repository.fetchAllUsers(user).then((List<User> list) {
        setState(() {
          userList = list;
        });
      });
    });
  }

  searchAppBar(BuildContext context) {
    return GradientAppBar(  
    // backgroundColorStart: UniversalVariables.gradientColorStart,
      // backgroundColorEnd: UniversalVariables.gradientColorEnd,
      gradient: LinearGradient(colors: [UniversalVariables.gradientColorStart, UniversalVariables.gradientColorEnd]),
       leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize( 
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(  
          padding: EdgeInsets.only(left:20),
          child: TextField(  
            controller: searchController,
            onChanged: (val){
              setState(() {
                query = val;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(  
              fontWeight: FontWeight.bold,
              fontSize: 35,
              color: Colors.white,
            ), 
            decoration: InputDecoration(  
              suffix: IconButton(  
                icon: Icon(Icons.close, color: Colors.white,),
                onPressed: (){
                  // searchController.clear(); throws an error -> solution below
                  WidgetsBinding.instance.addPostFrameCallback((_) => searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(  
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0x88ffffff),

              )

            ),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) { 
    final List<User> suggestionList = query.isEmpty
      ? []
      : userList.where((User user) { 
        String _getUsername = user.username.toLowerCase();
        String _query = query.toLowerCase();
        String _getName = user.name.toLowerCase();
        bool matchesUsername = _getUsername.contains(_query);
        bool matchesName = _getName.contains(_query);

        return (matchesUsername || matchesName);

        // (User user) => (user.username.toLowerCase().contains(query.toLowerCase()) || (user.name.toLowerCase().contains(query.toLowerCase())));
      }).toList();
      return ListView.builder( 
        itemCount: suggestionList.length,
        itemBuilder: ((context, index) { 
          User searchedUser = User(  
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].username
          );
          return CustomTile(  
            mini: false,
            onTap: (){ 
              Navigator.push(  
                context,
                MaterialPageRoute(  
                  builder: (context) => ChatScreen(  
                    receiver: searchedUser,
                  )));
            },
            leading: CircleAvatar( 
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(searchedUser.profilePhoto),
            ),
            title: Text(  
              searchedUser.username,
              style: TextStyle(  
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(  
              searchedUser.name,
              style:TextStyle(color: UniversalVariables.greyColor) ,
            ),
          );
        }) );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: searchAppBar(context),
      body:Container( 
        padding: EdgeInsets.symmetric(horizontal: 20),
        child:  buildSuggestions(query),
      )

      
    );
  }
}