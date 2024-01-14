import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/dto/Message.dart';
import '../dto/User.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<ChatPage> {
  var chats = <Message>[
  ];

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}