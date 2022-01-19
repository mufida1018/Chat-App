
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  final String fromId;
  final String toId;

  const ChatScreen({Key? key, required this.fromId, required this.toId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<dynamic> messageList = [] ;
  @override
  void initState() {
    // TODO: implement initState
    getMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Screen"),
      ),
      body: Container(
        height: height,
        child: Column(
            children: [

              Container(
                height: height-150,
                child: messageList != null ?
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: messageList.length,
                    itemBuilder:(context ,index){
                      var fromId = messageList[index]['fromId'];
                      if(fromId == widget.fromId){
                        return Row(

                          children:[
                            Spacer(),
                            Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(

                              width:  width*0.75,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(messageList[index]['message']),
                      ),

                            ),
                          ),
                      ]
                        );
                      }else{
                        return Row(
                          children: [ Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width:  width*0.75,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),

                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(messageList[index]['message']),
                              ),

                            ),
                          ),
                            Spacer(),
                      ]
                        );
                      }
                    }
                ):
                Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              Container(
                width: width,
                height: 70,
                color: Colors.blueGrey.withOpacity(0.4),
                child: Row(
                  children: [
                    Container(
                      width: width*0.8,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: width*0.15,
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.send,color: Colors.blue,size: 35),
                          onPressed: (){
                            sendMessageToDatabase();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }
  void sendMessageToDatabase(){

    if(messageController.text !="")
    {
      var timeStamp =DateTime.now().microsecondsSinceEpoch.toString();

      Map<String , dynamic>messageData ={
        'message':messageController.text,
        'toId': widget.toId,
        'fromId':  widget.fromId ,
        'timeStamp': timeStamp  ,
      };
      FirebaseFirestore.instance.collection('message').doc().set(messageData).then((value){
        messageController.text = "";
        setState(() {});
      });
    }else{
      Fluttertoast.showToast(msg: 'Cannot send blank message');
    }
  }
  void getMessage(){
    FirebaseFirestore.instance.collection('message').orderBy('timeStamp', descending: false).snapshots().listen((event) {
      if(event != null){
        var mList = event.docs;
        print('${mList}');
        messageList =[];
        for(var i =0;i<mList.length;i++){
          List ids =[mList[i]['toId'],mList[i]['fromId']];
          if(ids.contains(widget.fromId) && ids.contains(widget.toId)){
            messageList.add(mList[i]);
            setState(() {});
          }
        }

      }
    });
  }
}

