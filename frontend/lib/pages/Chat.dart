import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/dto/Message.dart';
import '../dto/User.dart';

class ChatPage extends StatefulWidget {
  User remoteUser;

  ChatPage({
    super.key,
    required this.remoteUser
  });

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<ChatPage> {
  var chats = [
  ];

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}