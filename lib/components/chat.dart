import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  late String chatName;
  late String ID;
  late String chatID;
  late DocumentSnapshot? lastMessage;
  Chat(
      {required this.chatName,
      required this.ID,
      required this.chatID,
      this.lastMessage});
  @override
  String toString() {
    return chatID;
  }
}
