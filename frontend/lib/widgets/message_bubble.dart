import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';

import '../dto/message_model.dart';
import '../dto/shared_item_model.dart';

class MessageBubble extends StatelessWidget {
  final SharedItemService sharedItemService = SharedItemService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final Message message;

  MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = message.sender == userId;

    return FractionallySizedBox(
      widthFactor: 1.0,
      child: Row(
        mainAxisAlignment:
            isPrimary ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: isPrimary
                    ? const Color.fromRGBO(189, 189, 189, 1.0)
                    : const Color.fromRGBO(200, 230, 201, 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: message.sharedItemId != null
                        ? FutureBuilder(
                            future: sharedItemService
                                .getSharedItem(message.sharedItemId!),
                            builder: (BuildContext context,
                                AsyncSnapshot<SharedItem?> sharedItemSnapshot) {
                              if (sharedItemSnapshot.hasData) {
                                final SharedItem? sharedItem =
                                    sharedItemSnapshot.data;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: sharedItem != null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Item: ${sharedItem.name}"),
                                            Text(
                                                "Amount: ${sharedItem.amount.nominal} ${sharedItem.amount.unit}")
                                          ],
                                        )
                                      : const Text(
                                          "Cannot obtain information of shared item"),
                                );
                              } else {
                                return const SizedBox(
                                  width: 0,
                                  height: 0,
                                );
                              }
                            })
                        : const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                  ),
                  Text(message.message)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
