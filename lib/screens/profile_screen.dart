import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followerLen = 0;
  int followingLen = 0;
  bool isFollowing = false;

  @override
  void initState() {
    getProfileData();
    super.initState();
  }

  getProfileData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      userData = userSnap.data()!;
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;
      followerLen = userSnap.data()!['followers'].length;
      followingLen = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediaQuery.of(context).size.width > webScreenSize
          ? webBackgroundColor
          : mobileBackgroundColor,
      appBar: MediaQuery.of(context).size.width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData.containsKey('username')
                  ? userData['username']
                  : 'Loading'),
              centerTitle: false,
            ),
      body: ListView(
        children: [
          Padding(
            padding: MediaQuery.of(context).size.width > webScreenSize
                ? const EdgeInsets.all(15)
                : const EdgeInsets.all(5),
            child: Column(
              children: [
                getProfileDetailsSection(
                    MediaQuery.of(context).size.width > webScreenSize),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      );
                    }
                    return GridView.builder(
                        shrinkWrap: true,
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          DocumentSnapshot snap =
                              (snapshot.data! as dynamic).docs[index];
                          return Image(
                            image: NetworkImage(
                              snap['postUrl'],
                            ),
                            fit: BoxFit.cover,
                          );
                        });
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container getProfileDetailsSection(bool isWeb) {
    return isWeb
        ? Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.14,
              vertical: 10,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData.containsKey('photoUrl')
                            ? userData['photoUrl']
                            : 'https://dreamvilla.life/wp-content/uploads/2017/07/dummy-profile-pic.png',
                      ),
                      radius: MediaQuery.of(context).size.width * 0.08,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  userData.containsKey('username')
                                      ? userData['username']
                                      : 'Loading',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontSize: 24,
                                  ),
                                ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? FollowButton(
                                        background: mobileBackgroundColor,
                                        borderColor: Colors.grey,
                                        text: "Sign Out",
                                        textColor: primaryColor,
                                        function: () async {
                                          AuthMethods().signOut();
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                      )
                                    : isFollowing
                                        ? FollowButton(
                                            background: Colors.white,
                                            borderColor: Colors.grey,
                                            text: "Unfollow",
                                            textColor: Colors.black,
                                            function: () async {
                                              await FirestoreMethods()
                                                  .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid']);
                                              setState(() {
                                                setState(() {
                                                  isFollowing = false;
                                                  followerLen--;
                                                });
                                              });
                                            },
                                          )
                                        : FollowButton(
                                            background: Colors.blue,
                                            borderColor: Colors.blue,
                                            text: "Follow",
                                            textColor: Colors.white,
                                            function: () async {
                                              await FirestoreMethods()
                                                  .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid']);
                                              setState(() {
                                                isFollowing = true;
                                                followerLen++;
                                              });
                                            },
                                          )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "Posts"),
                              buildStatColumn(followerLen, "Followers"),
                              buildStatColumn(followingLen, "Following"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData.containsKey('username')
                        ? userData['username']
                        : 'Loading',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData.containsKey('bio') ? userData['bio'] : 'loading',
                  ),
                ),
              ],
            ),
          )
        : Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: 10,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData.containsKey('photoUrl')
                            ? userData['photoUrl']
                            : 'https://dreamvilla.life/wp-content/uploads/2017/07/dummy-profile-pic.png',
                      ),
                      radius: 48,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "Posts"),
                              buildStatColumn(followerLen, "Followers"),
                              buildStatColumn(followingLen, "Following"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid ==
                                      widget.uid
                                  ? FollowButton(
                                      background: mobileBackgroundColor,
                                      borderColor: Colors.grey,
                                      text: "Sign Out",
                                      textColor: primaryColor,
                                      function: () async {
                                        AuthMethods().signOut();
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      },
                                    )
                                  : isFollowing
                                      ? FollowButton(
                                          background: Colors.white,
                                          borderColor: Colors.grey,
                                          text: "Unfollow",
                                          textColor: Colors.black,
                                          function: () async {
                                            await FirestoreMethods().followUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userData['uid']);
                                            setState(() {
                                              setState(() {
                                                isFollowing = false;
                                                followerLen--;
                                              });
                                            });
                                          },
                                        )
                                      : FollowButton(
                                          background: Colors.blue,
                                          borderColor: Colors.blue,
                                          text: "Follow",
                                          textColor: Colors.white,
                                          function: () async {
                                            await FirestoreMethods().followUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                userData['uid']);
                                            setState(() {
                                              isFollowing = true;
                                              followerLen++;
                                            });
                                          },
                                        )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData.containsKey('username')
                        ? userData['username']
                        : 'Loading',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData.containsKey('bio') ? userData['bio'] : 'loading',
                  ),
                ),
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        )
      ],
    );
  }
}
