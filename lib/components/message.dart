class Message {
  late String? ID;
  late String content;
  late String senderEmail;
  late DateTime? timeStamp;
  late List<String> read;
  Message(
      {this.ID,
      required this.content,
      required this.senderEmail,
      this.timeStamp,
      required this.read});
}
