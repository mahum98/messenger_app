//ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:messenger_app/components/chat.dart';
import 'package:messenger_app/pages/chat_page.dart';
import 'package:messenger_app/services/auth.dart';
import 'package:messenger_app/services/firestore_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  //initialize unfiltered chats
  List<Chat> chats = [];
  //error message
  String errorMessage = "";
  //chatCollection service
  ChatsCollection chatsCollection = ChatsCollection();
  //UserCollection service
  UsersCollection usersCollection = UsersCollection();
  //auth object
  Auth auth = Auth();
  //current user email
  String currentUserEmail = "";

  void refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    String userName = auth.currentUser!.email ?? "";
    int index = userName.indexOf("@");
    userName = userName.substring(0, index);
    currentUserEmail = userName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          title: Text(currentUserEmail),
          actions: [
            IconButton(
                onPressed: () {
                  auth.signOut();
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: StreamBuilder(
            stream: chatsCollection.getChatCollectionSnapshit(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //initialize chats as documentSnapshots
                List<DocumentSnapshot> documentSnapshots = snapshot.data!.docs;
                //initialize chats as Maps
                List<Map<String, dynamic>> mapchats = [];
                //populate Mapchats
                initializeMapChats(documentSnapshots, mapchats);
                //initialize unfiltered chats
                List<Chat> unfilteredchats = [];
                //chats defined above in class now just put them to empty
                chats = [];
                //populate unfiltered chats
                populateUnfilteredChats(mapchats, unfilteredchats);
                //populate chats
                populateChats(unfilteredchats);
                //future builder to get latest messages
                return FutureBuilder(future: () async {
                  for (var i = 0; i < chats.length; i++) {
                    chats[i].lastMessage = await chatsCollection
                        .lastMessageByChatID(chatID: chats[i].ID);
                  }
                }(), builder: (context, snapshot) {
                  //display chats
                  return ListView(
                      children: chats
                          .map((element) => chatTile(
                              chatName: element.chatName,
                              ID: element.ID,
                              currentUser: currentUserEmail,
                              lastMessage: element.lastMessage))
                          .toList());
                });
              }
              return Text("empty");
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return DialogcreateChat(
                      errorMessage: errorMessage,
                      currentUserEmail: currentUserEmail,
                      usersCollection: usersCollection,
                      chatsCollection: chatsCollection,
                      chats: chats);
                });
          },
          child: Icon(Icons.add),
        ));
  }

  void populateChats(List<Chat> unfilteredchats) {
    for (var i = 0; i < unfilteredchats.length; i++) {
      if (unfilteredchats[i].chatID.contains(currentUserEmail)) {
        chats.add(unfilteredchats[i]);
      }
    }
  }

  void populateUnfilteredChats(
      List<Map<String, dynamic>> mapchats, List<Chat> unfilteredchats) {
    for (var i = 0; i < mapchats.length; i++) {
      unfilteredchats.add(
        Chat(
            chatName: mapchats[i]["chatName"],
            ID: mapchats[i]["ID"],
            chatID: mapchats[i]["chatID"]),
      );
    }
  }

  void initializeMapChats(List<DocumentSnapshot<Object?>> documentSnapshots,
      List<Map<String, dynamic>> mapchats) {
    for (var i = 0; i < documentSnapshots.length; i++) {
      mapchats.add({
        "ID": documentSnapshots[i].id,
        "chatName": documentSnapshots[i].get("chatName"),
        "chatID": documentSnapshots[i].get("chatID")
      });
    }
  }

  Widget chatTile(
      {required String chatName,
      required String ID,
      required String currentUser,
      required DocumentSnapshot? lastMessage}) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      ID: ID,
                      senderEmail: currentUser,
                      refreshParentPage: refresh)));
        },
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: (lastMessage != null)
                ? lastMessage.get("read").contains(currentUserEmail)
                    ? Column(children: [
                        Text(lastMessage.get("content")),
                        Text(chatName)
                      ])
                    : Column(children: [
                        Text(lastMessage.get("content"),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(chatName)
                      ])
                : Column(children: [Text("no messages"), Text(chatName)])));
  }
}

// ignore: must_be_immutable
class DialogcreateChat extends StatefulWidget {
  DialogcreateChat(
      {super.key,
      required this.errorMessage,
      required this.currentUserEmail,
      required this.usersCollection,
      required this.chatsCollection,
      required this.chats});

  String errorMessage;
  String currentUserEmail;
  UsersCollection usersCollection;
  ChatsCollection chatsCollection;
  List<Chat> chats;

  @override
  State<DialogcreateChat> createState() => _DialogcreateChatState();
}

class _DialogcreateChatState extends State<DialogcreateChat> {
  //list of requested user emails
  List<String> requestedUserEmails = [];
  //chat name controller
  TextEditingController chatNameController = TextEditingController();
  //requested user controller
  TextEditingController requestedUserEmailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //chat name feild
          TextField(
            controller: chatNameController,
            decoration: InputDecoration(hintText: "chat name"),
          ),
          //add user feild
          TextField(
            controller: requestedUserEmailController,
            decoration: InputDecoration(hintText: "add user"),
          ),
          //error message
          Text(widget.errorMessage),
          //add user button
          TextButton(
              onPressed: () async {
                //clear error text
                setState(() {
                  widget.errorMessage = "";
                });
                //get requestedUserEmailController text
                String enteredEmail = requestedUserEmailController.text;
                //is entered email present in collection
                bool isEmailInUsersCollection = await UsersCollection()
                    .isEmailInUsersCollection(email: enteredEmail);
                //check wether isEmailInUsersCollection true or false
                if (isEmailInUsersCollection) {
                  //is entered email not present in requested emails list
                  if (!requestedUserEmails.contains(enteredEmail)) {
                    if (enteredEmail == widget.currentUserEmail) {
                      setState(() {
                        widget.errorMessage = "you cannot add yourself";
                      });
                    } else {
                      //populate requestedUserEmail list
                      requestedUserEmails.add(enteredEmail);
                      //set error statement to added
                      setState(() {
                        widget.errorMessage = "added";
                      });
                    }
                  } else {
                    setState(() {
                      widget.errorMessage = "User is already added";
                    });
                  }
                } else {
                  //set error statement to wrong email
                  setState(() {
                    widget.errorMessage = "wrong email";
                  });
                }
                //clear add user feild
                requestedUserEmailController.clear();
              },
              child: Text("add user")),
          //create chat button
          TextButton(
              onPressed: requestedUserEmails.isNotEmpty
                  ? () {
                      //add current user in requestedUserEmails list as well
                      requestedUserEmails.add(widget.currentUserEmail);
                      //generate chatID
                      String chatID = generatechatID(
                          requestedUsersEmails: requestedUserEmails);
                      //to prevent multiple instances of same chat
                      if (!ischatIDalreadyInAvailableChats(
                          chatID: chatID, chats: widget.chats)) {
                        //populate chatCollection
                        widget.chatsCollection.createChat(
                            chatName: chatNameController.text, chatID: chatID);
                        //after chat is created: clear requestedUserEmails
                        setState(() {
                          Navigator.pop(context);
                        });
                      } else {
                        //requestedUsersList to empty
                        requestedUserEmails = [];
                        //set feilds to empty
                        chatNameController.clear();
                        requestedUserEmailController.clear();
                        //set error
                        setState(() {
                          widget.errorMessage = "you already have this chat";
                        });
                      }
                    }
                  : null,
              child: Text("create chat"))
        ],
      ),
    ));
  }

  bool ischatIDalreadyInAvailableChats(
      {required String chatID, required List<Chat> chats}) {
    bool flag = false;
    for (var i = 0; i < chats.length; i++) {
      if (chats[i].chatID == chatID) {
        flag = true;
      }
    }
    return flag;
  }

  String generatechatID({required List<String> requestedUsersEmails}) {
    requestedUsersEmails.sort();
    String s = "";
    for (var i = 0; i < requestedUsersEmails.length; i++) {
      s = s + requestedUsersEmails[i];
    }
    return s;
  }
}
