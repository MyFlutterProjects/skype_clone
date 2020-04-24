import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skype_clone/enum/user_state.dart';
import 'package:skype_clone/pageViews/chart_list_screen.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/firebase_methods.dart';
import 'package:skype_clone/screens/callScreens/pickup/pickup_layout.dart';
import 'package:skype_clone/utils/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with WidgetsBindingObserver {
  PageController pageController;
  int _page = 0;
  double _labelFontSize = 10.0;
  UserProvider userProvider;
  FirebaseMethods _authMethods = FirebaseMethods();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pageController = PageController(); // initialize page controller
   

    // init is called before build so there will be an error 
    // solution
    SchedulerBinding.instance.addPostFrameCallback((_) {
       userProvider = Provider.of<UserProvider>(context, listen: false);
       userProvider.refreshUser();

       _authMethods.setUserState( 
    userId: userProvider.getUser.uid,
    userState: UserState.online,

  );
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  
  
  @override 
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
     (userProvider !=null &&   userProvider.getUser != null)
     ? userProvider.getUser.uid
     :"";

     super.didChangeAppLifecycleState(state);

       switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.offline)
            : print("detached state");
        break;
    }

  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return PickUpLayout(
          scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        body: PageView(
          children: <Widget>[
            Center(
              child: ChatListScreen(),
            ),
            Center(
              child: Text('Call Logs',  style: TextStyle(color: Colors.white)),
            ),
            Center(
              child: Text('Contact Screen',  style: TextStyle(color: Colors.white)),
            ),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(), // disable page  scroll
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: UniversalVariables.blackColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat,
                    color: (_page == 0)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  title: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: _labelFontSize,
                      color: (_page == 0)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor,
                    ),
                  ),
                ),
                   BottomNavigationBarItem(
                  icon: Icon(
                    Icons.call,
                    color: (_page == 1)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  title: Text(
                    'Call',
                    style: TextStyle(
                      fontSize: _labelFontSize,
                      color: (_page == 1)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor,
                    ),
                  ),
                ),
                   BottomNavigationBarItem(
                  icon: Icon(
                    Icons.contact_phone,
                    color: (_page == 2)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  title: Text(
                    'Contacts',
                    style: TextStyle(
                      fontSize: _labelFontSize,
                      color: (_page == 2)
                          ? UniversalVariables.lightBlueColor
                          : UniversalVariables.greyColor,
                    ),
                  ),
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
              
            ),
          ),
        ),
      ),
    );
  }
}
