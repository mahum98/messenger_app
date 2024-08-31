//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:messenger_app/components/message.dart';
import 'package:messenger_app/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  ChatPage(
      {super.key,
      required this.ID,
      required this.senderEmail,
      required this.refreshParentPage});
  //the ID you will get from HomePage
  late String ID;
  //the User email you will get from HomePage
  late String senderEmail;
  //refresh parent page
  late Function refreshParentPage;
  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  //initialize chatsCollection services
  ChatsCollection chatsCollection = ChatsCollection();
  //controller
  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: StreamBuilder(
                stream: chatsCollection.readMessages(chatID: widget.ID),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //initialize documents list
                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    //initialize mapMessages list
                    List<Map<String, dynamic>> mapMessages = [];
                    //initialize messages
                    List<Message> messages = [];
                    //populate mapMessages
                    populateMapMessages(documents, mapMessages);
                    //populate messages
                    populateMessages(mapMessages, messages);
                    //mark messages as read
                    markMessagesRead(messages);
                    //refresh parent page
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.refreshParentPage();
                    });

                    //display
                    return Column(
                      children: [
                        Expanded(
                            child: ListView(
                                children: messages
                                    .map((element) => messageTile(
                                        content: element.content,
                                        sender: element.senderEmail,
                                        read: element.read))
                                    .toList())),
                        //text feild
                        Row(
                          children: [
                            Expanded(
                                child: TextField(
                              controller: messageController,
                            )),
                            //send button
                            TextButton(
                                onPressed: () {
                                  //Make message object to send
                                  Message message = Message(
                                      content: messageController.text,
                                      senderEmail: widget.senderEmail,
                                      read: [widget.senderEmail]);
                                  //send message
                                  chatsCollection.sendMessage(
                                      chatID: widget.ID,
                                      content: message.content,
                                      sender: message.senderEmail,
                                      read: message.read);
                                  //update timeStamp
                                  chatsCollection.updateTimeStamp(
                                      chatID: widget.ID);
                                  //clear feild
                                  messageController.clear();
                                },
                                child: Text("send"))
                          ],
                        ),
                        SizedBox(height: 20)
                      ],
                    );
                  }
                  return Text("empty");
                })));
  }

  void markMessagesRead(List<Message> messages) {
    for (var i = 0; i < messages.length; i++) {
      if (!messages[i].read.contains(widget.senderEmail)) {
        messages[i].read.add(widget.senderEmail);
        chatsCollection.updateMessageReadStatus(
            chatID: widget.ID,
            messageID: messages[i].ID,
            readBy: messages[i].read);
      }
    }
  }

  void populateMessages(
      List<Map<String, dynamic>> mapMessages, List<Message> messages) {
    for (var i = 0; i < mapMessages.length; i++) {
      messages.add(Message(
          ID: mapMessages[i]["ID"],
          content: mapMessages[i]["content"],
          senderEmail: mapMessages[i]["sender"],
          timeStamp: mapMessages[i]["timeStamp"].toDate(),
          read: List<String>.from(
              mapMessages[i]["read"]) // Casting to List<String>
          ));
    }
  }

  void populateMapMessages(List<DocumentSnapshot<Object?>> documents,
      List<Map<String, dynamic>> mapMessages) {
    for (var i = 0; i < documents.length; i++) {
      mapMessages.add({
        "ID": documents[i].id,
        "content": documents[i].get("content"),
        "sender": documents[i].get("sender"),
        "timeStamp": documents[i].get("timeStamp"),
        "read": documents[i].get("read")
      });
    }
  }

  Widget messageTile(
      {required String content,
      required String sender,
      required List<String> read}) {
    if (sender == widget.senderEmail) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(content),
          //Text(": $read")
        ])
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(content),
        //Text(": $read")
      ])
    ]);
  }
}
