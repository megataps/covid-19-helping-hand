import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helping_hand/components/counter.dart';
import 'package:helping_hand/config/config.dart';
import 'package:helping_hand/config/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helping_hand/screens/editProfile.dart';
import 'package:helping_hand/screens/faqScreen.dart';

import 'package:helping_hand/screens/loginScreen.dart';
import 'package:helping_hand/screens/newsUpdateScreen.dart';
import 'package:helping_hand/screens/requestDisplay.dart';
import 'request_form.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showSpinner = false;
  int pageIndex = 0;
  PageController pageController;

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Map<String, dynamic> g = {
    'displayName': 'N/A',
    'photUrl':
        'https://firebasestorage.googleapis.com/v0/b/helping-hand-76970.appspot.com/o/default-user-img.png?alt=media&token=d96df74f-5b3b-4f08-86f8-d1a913459e07',
    'points': 0,
    'username': 'N/A',
    'bio': 'N/A',
    'peopleHelped': 0,
    'email': 'N/A'
  };

  Future<void> get_user_info() async {
    final auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final userID = user.uid;
    final DocumentReference users =
        Firestore.instance.document('users/' + userID);
    await for (var snapshot in users.snapshots()) {
      setState(() {
        var combinedMap = {...?g, ...?snapshot.data};
        g = combinedMap;
        if (g['photUrl'] == null || g['photUrl'] == "") {
          g.update(
              'photUrl',
              (v) =>
                  'https://firebasestorage.googleapis.com/v0/b/helping-hand-76970.appspot.com/o/default-user-img.png?alt=media&token=d96df74f-5b3b-4f08-86f8-d1a913459e07');
        }
      });
    }
  }

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    get_user_info();
    super.initState();
  }

  logout() async {
    await FirebaseAuth.instance.signOut();
    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.signOut();
    setState(() {
      showSpinner = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //this little code down here turns off auto rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(g['displayName']),
                accountEmail: Text(g['email']),
                currentAccountPicture: GestureDetector(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      g['photUrl'],
                      height: 90,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FAQPage()));
                },
                child: ListTile(
                  title: Text(
                    "FAQ's",
                    style: kTitleTextstyle,
                  ),
                  leading: Icon(Icons.help),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();

                  logout();
                },
                child: ListTile(
                  title: Text(
                    'Sign Out',
                    style: kTitleTextstyle,
                  ),
                  leading: Icon(Icons.exit_to_app),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    'Edit Profile',
                    style: kTitleTextstyle,
                  ),
                  leading: Icon(
                    Icons.edit,
                    color: secondaryColor,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  //
                },
                child: ListTile(
                  title: Text(
                    'About',
                    style: kTitleTextstyle,
                  ),
                  leading: Icon(
                    Icons.code,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: PageView(
          children: <Widget>[
            NewsUpdateScreen(),
            Container(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  CustomTitleBar(
                    img: g['photUrl'],
                  ),
                  NameAndUsername(
                    name: g['displayName'],
                    username: "@" + g['username'],
                    bio: g['bio'],
                    img: g['photUrl'],
                  ),
                  Statusbar(
                    points: g['points'],
                    peoplehelped: g['peopleHelped'],
                  ),
                  HotList(),
                  RequestSendAssist(),
                ],
              ),
            ),
            requestDisplay(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          color: primaryColor,
          backgroundColor: secondaryColor,
          buttonBackgroundColor: Colors.white70,
          height: 50,
          items: <Widget>[
            Icon(
              Icons.home,
              size: 25,
              color: Colors.white,
            ),
            Icon(
              Icons.person,
              size: 25,
              color: Colors.white,
            ),
            Icon(
              Icons.filter_list,
              size: 25,
              color: Colors.white,
            ),
          ],
          index: pageIndex,
          onTap: onTap,
        ),
      ),
    );
  }
}

class CustomTitleBar extends StatelessWidget {
  final String img;

  const CustomTitleBar({Key key, this.img}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              iconSize: 25.0,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            IconButton(
              icon: Icon(Icons.message),
              iconSize: 25.0,
              onPressed: () {
                //navigate to message screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NameAndUsername extends StatelessWidget {
  final String name;
  final String username;
  final String bio;
  final String img;

  const NameAndUsername({Key key, this.name, this.username, this.bio, this.img})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 30, left: 30, right: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: titleTextStyle,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  img,
                  height: 90,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              username,
              style: primaryBodyTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Bio: " + bio.toString(),
              style: bodyTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class Statusbar extends StatelessWidget {
  final int points;
  final int peoplehelped;

  const Statusbar({Key key, this.points, this.peoplehelped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 16, right: 16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Helping Hand Reputation\n",
                              style: kTitleTextstyle,
                            ),
                            TextSpan(
                              text: "Updated Daily",
                              style: TextStyle(
                                color: kTextLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 30,
                          color: kShadowColor,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Counter(
                          color: secondaryColor,
                          number: points,
                          title: "Total Perks",
                        ),
                        Counter(
                          color: kRecovercolor,
                          number: peoplehelped,
                          title: "People helped",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HotList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "What are you upto today?",
            style: kTitleTextstyle,
          ),
        ],
      ),
    );
  }
}

class RequestSendAssist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              var route = new MaterialPageRoute(
                builder: (BuildContext context) => new request_form(),
              );
              Navigator.of(context).push(route);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              color: secondaryColor,
              elevation: 0,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/help.png',
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                title: Text(
                  'Request Assist',
                  style: titleTextStyle.apply(
                      color: Colors.white, fontSizeDelta: 0.2),
                ),
                subtitle: Text(
                  "Let your neighbours help",
                  style: bodyTextStyle,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              var route = new MaterialPageRoute(
                builder: (BuildContext context) => new requestDisplay(),
              );
              Navigator.of(context).push(route);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              color: primaryColor,
              elevation: 0,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/help-others.png',
                    width: 50,
                    fit: BoxFit.contain,
                  ),
                ),
                title: Text(
                  'Help Others',
                  style: titleTextStyle.apply(
                      color: Colors.white, fontSizeDelta: 0.2),
                ),
                subtitle: Text(
                  "See who needs your help",
                  style: bodyTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
