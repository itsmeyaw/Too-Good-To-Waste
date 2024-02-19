import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/service/message_service.dart';
import 'package:tooGoodToWaste/service/user_service.dart';
import 'package:tooGoodToWaste/widgets/message_bubble.dart';
import 'package:tooGoodToWaste/widgets/verifiable_text_field.dart';

import '../dto/message_model.dart';
import '../dto/user_model.dart';

class ChatroomPage extends StatefulWidget {
  final String secondUserId;
  final SharedItem? sharedItem;

  const ChatroomPage({super.key, required this.secondUserId, this.sharedItem});

  @override
  State<StatefulWidget> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  final MessageService messageService = MessageService();
  final UserService userService = UserService();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _messageValidator =
      ValidationBuilder().required("Please fill the message").build();
  bool alreadySendItem = false;

  List<Message> messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: FutureBuilder(
            future: userService.getUserData(widget.secondUserId),
            builder: (BuildContext context,
                AsyncSnapshot<TGTWUser> secondUserSnapshot) {
              if (secondUserSnapshot.hasData &&
                  secondUserSnapshot.data != null) {
                return Text(
                    "Messages with ${secondUserSnapshot.data!.name.last}");
              } else {
                return const Text("Messages");
              }
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream:
                        messageService.getMessageStream(widget.secondUserId),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Message>> messagesSnapshot) {
                      if (messagesSnapshot.connectionState ==
                              ConnectionState.active &&
                          messagesSnapshot.hasData) {
                        if (messagesSnapshot.data != null) {
                          messages = messagesSnapshot.data!;
                          messages.sort((Message a, Message b) {
                            return b.timestamp.millisecondsSinceEpoch -
                                a.timestamp.millisecondsSinceEpoch;
                          });

                          return ListView(
                            reverse: true,
                            children: messages
                                .map((message) => Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        MessageBubble(message: message)
                                      ],
                                    ))
                                .toList(),
                          );
                        }
                      }
                      return Container();
                    })),
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: VerifiableTextField(
                        controller: _messageController,
                        validator: _messageValidator,
                        labelText: "Message",
                        onChanged: (String value) {},
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            messageService.sendMessage(
                                widget.secondUserId,
                                _messageController.value.text,
                                alreadySendItem ? null : widget.sharedItem?.id);
                            _messageController.text = "";
                            alreadySendItem = true;
                          });
                        },
                        icon: const Icon(Icons.send)),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
