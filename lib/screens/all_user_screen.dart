import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterflashapp/screens/chat_screen.dart';
import 'package:flutterflashapp/screens/login_screen.dart';

class AllUserScreen extends StatefulWidget {
  @override
  _AllUserScreenState createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
   var uid;
  List<dynamic> allUsers = [];

  @override
  void initState() {
    var currentUser = FirebaseAuth.instance.currentUser;
    uid = currentUser!.uid;
    getCurrentUserUid();
    getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flash Chat"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance
                ..signOut().then((value) {
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()), (
                          route) => false);
                });
            },)
        ],
      ),
      body: allUsers != null ?
      ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        children: [
                          Text("${allUsers[index]['name']}", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),),
                          Text("${allUsers[index]['email']}",
                              style: TextStyle(fontSize: 10)),
                        ]
                    ),
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                  toId:allUsers[index]['uid'],
                  fromId:uid,
              )));
            },
          );
        },

      ) : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void getAllUsers() {
    FirebaseFirestore.instance.collection('users').get().then((value) {
      if (value != null) {
       var usersList = value.docs;
       for(var i= 0;i<usersList.length ;i++){
         var userId = usersList[i]['uid'];
         if(userId != uid){
           allUsers.add(usersList[i]);
         }
       }
        setState(() {});
      }
    });
  }
  void getCurrentUserUid() async{
    var user = await FirebaseAuth.instance.currentUser;
    uid = user!.uid;
  }
}

