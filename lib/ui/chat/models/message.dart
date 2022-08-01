class Message {
  int id;
  String text;
  DateTime time;
  String userId;
  bool user;

  Message({
    required this.userId,
    required this.id,
    required this.text,
    required this.time,
    required this.user,
  });
}
