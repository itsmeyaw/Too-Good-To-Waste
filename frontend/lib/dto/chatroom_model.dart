import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import './message_model.dart';

part 'chatroom_model.g.dart';

@immutable
@JsonSerializable()
class Chatroom {
  final String initiator;
  final String receiver;
  final List<Message> messages;

  const Chatroom(
      {required this.initiator,
      required this.receiver,
      required this.messages});

  factory Chatroom.fromJson(Map<String, dynamic> json) => _$ChatroomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatroomToJson(this);
}
