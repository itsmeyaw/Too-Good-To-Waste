import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/pages/chatroom.dart';
import 'package:tooGoodToWaste/service/message_service.dart';
import 'package:tooGoodToWaste/service/user_service.dart';

import '../dto/user_model.dart';

class MessageThreadList extends StatefulWidget {
  const MessageThreadList({super.key});

  @override
  State<StatefulWidget> createState() => _MessageThreadListState();
}

class _MessageThreadListState extends State<MessageThreadList> {
  final Logger logger = Logger();
  final MessageService messageService = MessageService();
  final UserService userService = UserService();
  List<String> secondUsers = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: messageService.getMessageThreadStream(),
        builder: (BuildContext context,
            AsyncSnapshot<List<String>> secondUsersSnapshot) {
          if (secondUsersSnapshot.connectionState == ConnectionState.active &&
              secondUsersSnapshot.hasData) {
            if (secondUsersSnapshot.data != null) {
              logger.d("Got data ${secondUsersSnapshot.data!.length} items");
              secondUsers = secondUsersSnapshot.data!;

              return ListView.separated(
                  itemBuilder: (_, index) {
                    return FutureBuilder(
                        future: userService.getUserData(secondUsers[index]),
                        builder: (BuildContext context,
                            AsyncSnapshot<TGTWUser> userSnapshot) {
                          if (userSnapshot.hasData &&
                              userSnapshot.data != null) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ChatroomPage(
                                                secondUserId:
                                                    secondUsers[index])));
                              },
                              child: ListTile(
                                title: Text(
                                    "${userSnapshot.data!.name.first} ${userSnapshot.data!.name.last}"),
                              ),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        });
                  },
                  separatorBuilder: (_, index) => const Divider(
                        height: 10,
                      ),
                  itemCount: secondUsers.length);
            }
          }
          return Container();
        });
  }
}
