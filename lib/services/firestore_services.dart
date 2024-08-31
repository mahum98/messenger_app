import 'package:cloud_firestore/cloud_firestore.dart';

class UsersCollection {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection("UsersCollection");

  //checks if email checks with users in usersCollection
  Future<bool> isEmailInUsersCollection({required email}) async {
    QuerySnapshot querySnapshot =
        await usersCollection.where("email", isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty ? true : false;
  }

  //add a user to UsersCollection
  Future<void> addUserEmail({required String userEmail}) {
    return usersCollection.add({"email": userEmail});
  }
}

class ChatsCollection {
  CollectionReference chatsCollection =
      FirebaseFirestore.instance.collection("ChatsCollection");

  //create a chat collection
  Future<void> createChat(
      {required String chatName, required String chatID}) async {
    await chatsCollection.add(
        {"chatName": chatName, "chatID": chatID, "timeStamp": Timestamp.now()});
  }

  //read chat collection
  Stream<QuerySnapshot> getChatCollectionSnapshit() {
    return chatsCollection.orderBy("timeStamp", descending: true).snapshots();
  }

  //send a message
  Future<void> sendMessage(
      {required String chatID,
      required String content,
      required String sender,
      required List<String> read}) async {
    //get message collection using chatID
    DocumentReference documentReference = chatsCollection.doc(chatID);
    CollectionReference messageCollection =
        documentReference.collection("messagesCollection");
    //add a message in that collection
    await messageCollection.add({
      "content": content,
      "sender": sender,
      "timeStamp": Timestamp.now(),
      "read": read
    });
  }

  //read a message
  Stream<QuerySnapshot> readMessages({required String chatID}) {
    //get message collection using chatID
    DocumentReference documentReference = chatsCollection.doc(chatID);
    CollectionReference messageCollection =
        documentReference.collection("messagesCollection");
    //return
    return messageCollection.orderBy("timeStamp").snapshots();
  }

  //update the timeStamp of chat
  Future<void> updateTimeStamp({required chatID}) {
    return chatsCollection.doc(chatID).update({"timeStamp": Timestamp.now()});
  }

  //update read status of chat
  Future<void> updateMessageReadStatus(
      {required String chatID,
      required String? messageID,
      required List<String> readBy}) {
    //get message collection using chatID
    DocumentReference documentReference = chatsCollection.doc(chatID);
    CollectionReference messageCollection =
        documentReference.collection("messagesCollection");
    //update a message
    return messageCollection.doc(messageID).update({"read": readBy});
  }

  //get last message by chatID
  Future<DocumentSnapshot?>? lastMessageByChatID(
      {required String chatID}) async {
    //get message collection using chatID
    DocumentReference documentReference = chatsCollection.doc(chatID);
    CollectionReference messageCollection =
        documentReference.collection("messagesCollection");
    QuerySnapshot querySnapshot = await messageCollection
        .orderBy("timeStamp", descending: true)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.last;
    }
    return null;
  }
}
